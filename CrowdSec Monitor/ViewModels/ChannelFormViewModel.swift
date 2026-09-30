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

    static let ntfyPriorities = ["min", "low", "default", "high", "urgent", "max"]

    @ObservationIgnored private let activeServerRepository: ActiveServerRepository
    @ObservationIgnored private let editing: UserNotificationChannel?

    var isEditing: Bool { editing != nil }

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

    var selectedStep = 0
    var provider: NotificationChannelType?
    var name = ""

    var ntfyTopic = ""
    var ntfyServer = ""
    var ntfyUsername = ""
    var ntfyPassword = ""
    var ntfyAccessToken = ""
    var ntfyPriority = "default"
    var ntfyTags = ""

    var emailHost = ""
    var emailPort = "587"
    var emailSecure = false
    var emailUsername = ""
    var emailPassword = ""
    var emailFrom = ""
    var emailTo = ""

    var testState: ChannelTestState = .idle
    var isSaving = false
    var saveError = false

    func load(channel: UserNotificationChannel) {
        provider = channel.type
        name = channel.name
        let config = channel.config
        ntfyTopic = config.topic ?? ""
        ntfyServer = config.server ?? ""
        ntfyUsername = config.username ?? ""
        ntfyPassword = config.password ?? ""
        ntfyAccessToken = config.accessToken ?? ""
        ntfyPriority = config.priority ?? "default"
        ntfyTags = config.tags ?? ""
        emailHost = config.host ?? ""
        if let port = config.port {
            emailPort = String(port)
        }
        emailSecure = config.secure ?? false
        emailUsername = config.username ?? ""
        emailPassword = config.password ?? ""
        emailFrom = config.from ?? ""
        emailTo = config.to ?? ""
    }

    func buildConfig() -> NotificationChannelConfig? {
        guard let provider else { return nil }
        switch provider {
        case .ntfy:
            guard !ntfyTopic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
            return NotificationChannelConfig(
                server: orNil(ntfyServer),
                topic: ntfyTopic.trimmingCharacters(in: .whitespacesAndNewlines),
                username: orNil(ntfyUsername),
                password: orNil(ntfyPassword),
                accessToken: orNil(ntfyAccessToken),
                priority: ntfyPriority,
                tags: orNil(ntfyTags)
            )
        case .email:
            guard
                !emailHost.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                !emailFrom.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                !emailTo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else { return nil }
            let port = Int(emailPort.trimmingCharacters(in: .whitespacesAndNewlines))
            return NotificationChannelConfig(
                username: orNil(emailUsername),
                password: orNil(emailPassword),
                host: emailHost.trimmingCharacters(in: .whitespacesAndNewlines),
                port: port,
                secure: emailSecure,
                from: emailFrom.trimmingCharacters(in: .whitespacesAndNewlines),
                to: emailTo.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }
    }

    func providerValid() -> Bool {
        buildConfig() != nil
    }

    func nameValid() -> Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func test() async {
        guard let apiClient = activeServerRepository.apiClient else { return }
        guard let provider, let config = buildConfig() else { return }
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
                    body: TestInlineChannelRequest(type: provider, config: config, message: message)
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
        guard let provider, let config = buildConfig() else { return nil }
        isSaving = true
        defer { isSaving = false }
        do {
            if let editing {
                let body = UpdateChannelRequest(
                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                    type: provider, config: config
                )
                let response = try await apiClient.notificationChannels.updateChannel(
                    channelId: editing.id, body: body
                )
                return response.body.data
            } else {
                let body = CreateChannelRequest(
                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                    type: provider, config: config
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

    private func orNil(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
