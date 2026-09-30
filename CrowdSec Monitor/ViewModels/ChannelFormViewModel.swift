import Foundation
import SwiftUI

enum ChannelTestState: Equatable, Sendable {
    case idle
    case testing
    case success
    case failure(String)
}

@MainActor
@Observable
class ChannelFormViewModel {

    @ObservationIgnored private let activeServerRepository: ActiveServerRepository
    @ObservationIgnored private let editing: UserNotificationChannel?

    var isEditing: Bool { editing != nil }

    var selectedStep = 0

    init(
        editing channel: UserNotificationChannel? = nil,
        activeServerRepository: ActiveServerRepository = RepositoriesContainer.shared.activeServerRepository
    ) {
        self.editing = channel
        self.activeServerRepository = activeServerRepository
        if let channel {
            load(channel: channel)
        }
    }

    var providers: [NotificationProvider] = []
    var providerType: String?
    var values: [String: JSONValue] = [:]
    var name = ""

    var testState: ChannelTestState = .idle
    var isSaving = false
    var saveError = false
    var loadError = false

    var definition: NotificationProvider? {
        providers.first { $0.type == providerType }
    }

    func load(channel: UserNotificationChannel) {
        providerType = channel.type.rawValue
        name = channel.name
        values = channel.config
    }

    func loadProviders() async {
        guard let apiClient = activeServerRepository.apiClient else { return }
        do {
            let response = try await apiClient.notificationChannels.fetchProviders()
            providers = response.body.providers
            applyDefaults()
        } catch {
            guard !(error is CancellationError) else { return }
            loadError = true
        }
    }

    func selectProvider(_ type: String) {
        providerType = type
        applyDefaults()
    }

    /// Fill definition defaults for missing keys so displayed selections
    /// always match a picker tag (avoids invalid-selection warnings).
    private func applyDefaults() {
        guard let definition else { return }
        for field in definition.fields {
            if values[field.key] == nil, let def = field.defaultValue {
                values[field.key] = def
            }
        }
    }

    // MARK: - Field evaluation

    private func isPresent(_ value: JSONValue?) -> Bool {
        value?.isPresent ?? false
    }

    private func conditionHolds(_ condition: ProviderFieldCondition) -> Bool {
        let value = values[condition.field]
        if let present = condition.present {
            return present ? isPresent(value) : !isPresent(value)
        }
        if let expected = condition.equals {
            return value == expected
        }
        return false
    }

    func visibleFields() -> [ProviderField] {
        guard let definition else { return [] }
        return definition.fields.filter { field in
            guard let visibleIf = field.visibleIf else { return true }
            return conditionHolds(visibleIf)
        }
    }

    /// Visible fields grouped by section in definition order; fields without
    /// (or with unknown) section come last, ungrouped (`section` is nil).
    func groupedFields() -> [(section: ProviderSection?, fields: [ProviderField])] {
        let visible = visibleFields()
        let known = Set((definition?.sections ?? []).map { $0.key })
        var groups: [(section: ProviderSection?, fields: [ProviderField])] = []
        for section in definition?.sections ?? [] {
            let fields = visible.filter { $0.section == section.key }
            if !fields.isEmpty {
                groups.append((section: section, fields: fields))
            }
        }
        let ungrouped = visible.filter { $0.section == nil || !known.contains($0.section ?? "") }
        if !ungrouped.isEmpty {
            groups.append((section: nil, fields: ungrouped))
        }
        return groups
    }

    func displayValue(for field: ProviderField) -> JSONValue? {
        values[field.key] ?? field.defaultValue
    }

    func stringBinding(for key: String) -> Binding<String> {
        Binding(
            get: { self.values[key]?.displayString ?? "" },
            set: { self.values[key] = .string($0) }
        )
    }

    func boolBinding(for key: String, default defaultValue: Bool = false) -> Binding<Bool> {
        Binding(
            get: {
                if case .bool(let value) = self.values[key] {
                    return value
                }
                return defaultValue
            },
            set: { self.values[key] = .bool($0) }
        )
    }

    // MARK: - Validation (light; the backend enforces strictly)

    func isFieldValid(_ field: ProviderField) -> Bool {
        let value = values[field.key]
        let required = field.required == true
            || (field.requiredIf.map(conditionHolds) ?? false)
        if !isPresent(value) {
            return !required
        }
        switch field.type {
        case "text", "password":
            guard case .string(let text) = value else { return false }
            if let min = field.minLength, text.count < min { return false }
            if let max = field.maxLength, text.count > max { return false }
            if let pattern = field.regex {
                guard (try? NSRegularExpression(pattern: pattern))?.firstMatch(
                    in: text, range: NSRange(text.startIndex..., in: text)
                ) != nil else { return false }
            }
            return true
        case "email":
            guard case .string(let text) = value else { return false }
            return text.split(separator: ",").allSatisfy { part in
                let address = part.trimmingCharacters(in: .whitespaces)
                return address.contains("@") && address.contains(".")
            }
        case "url":
            guard case .string(let text) = value else { return false }
            return text.hasPrefix("http://") || text.hasPrefix("https://")
        case "number":
            let number: Double
            switch value {
            case .string(let text) where !text.isEmpty:
                guard let parsed = Double(text) else { return false }
                number = parsed
            case .int(let int):
                number = Double(int)
            case .double(let double):
                number = double
            default:
                return false
            }
            if field.integer == true && number.truncatingRemainder(dividingBy: 1) != 0 { return false }
            if let min = field.min, number < min { return false }
            if let max = field.max, number > max { return false }
            return true
        case "boolean":
            return value?.isPresent ?? false
        case "select":
            guard case .string(let text) = value else { return false }
            return field.options?.contains { $0.value == text } ?? false
        default:
            return true
        }
    }

    func providerValid() -> Bool {
        guard providerType != nil else { return false }
        let fields = visibleFields()
        guard fields.allSatisfy(isFieldValid) else { return false }
        let present = Set(values.keys.filter { isPresent(values[$0]) })
        for field in fields where present.contains(field.key) {
            if let exclusive = field.exclusiveWith, exclusive.contains(where: { present.contains($0) }) {
                return false
            }
        }
        return true
    }

    func nameValid() -> Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Payload

    func buildPayload() -> [String: JSONValue]? {
        guard let definition, providerValid() else { return nil }
        var payload: [String: JSONValue] = [:]
        for field in definition.fields {
            guard let value = values[field.key], value.isPresent else { continue }
            switch field.type {
            case "number":
                if case .string(let text) = value {
                    if field.integer == true, let int = Int(text) {
                        payload[field.key] = .int(int)
                    } else if let double = Double(text) {
                        payload[field.key] = .double(double)
                    }
                } else {
                    payload[field.key] = value
                }
            default:
                payload[field.key] = value
            }
        }
        return payload
    }

    // MARK: - Test & save

    func test() async {
        guard let apiClient = activeServerRepository.apiClient else { return }
        guard let providerType, let payload = buildPayload() else { return }
        testState = .testing
        do {
            let message = "Test notification from \"\(name.trimmingCharacters(in: .whitespacesAndNewlines))\""
            let result: HttpResponse<ChannelTestResponse>
            if let editing {
                result = try await apiClient.notificationChannels.testChannel(
                    channelId: editing.id, body: TestChannelRequest(message: message)
                )
            } else {
                result = try await apiClient.notificationChannels.testInlineChannel(
                    body: TestInlineChannelRequest(type: providerType, config: payload, message: message)
                )
            }
            if result.body.data.ok {
                testState = .success
            } else {
                testState = .failure(result.body.data.detail ?? "Unknown error")
            }
        } catch {
            guard !(error is CancellationError) else {
                testState = .idle
                return
            }
            testState = .failure(error.localizedDescription)
        }
    }

    func save() async -> UserNotificationChannel? {
        guard let apiClient = activeServerRepository.apiClient else { return nil }
        guard let providerType, let payload = buildPayload() else { return nil }
        isSaving = true
        defer { isSaving = false }
        do {
            if let editing {
                let body = UpdateChannelRequest(
                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                    type: providerType, config: payload
                )
                let response = try await apiClient.notificationChannels.updateChannel(
                    channelId: editing.id, body: body
                )
                return response.body.data
            } else {
                let body = CreateChannelRequest(
                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                    type: providerType, config: payload
                )
                let response = try await apiClient.notificationChannels.createChannel(body: body)
                return response.body.data
            }
        } catch {
            guard !(error is CancellationError) else { return nil }
            saveError = true
            return nil
        }
    }
}
