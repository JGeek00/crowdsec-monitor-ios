import Foundation
import SwiftUI

enum RulesValidationIssue: Equatable, Sendable {
    case empty
    case incomplete
    case advanced
    case invalidWindow
}

struct NotificationFilterOptions: Sendable {
    var scenarios: [String] = []
    var countries: [String] = []
    var targets: [String] = []
    var ipOwners: [String] = []
}

@MainActor
@Observable
class NotificationFormViewModel {

    @ObservationIgnored private let activeServerRepository: ActiveServerRepository
    @ObservationIgnored private let editing: UserNotification?

    var isEditing: Bool { editing != nil }

    init(
        editing notification: UserNotification? = nil,
        activeServerRepository: ActiveServerRepository = RepositoriesContainer.shared.activeServerRepository
    ) {
        self.editing = notification
        self.activeServerRepository = activeServerRepository
        if let notification {
            load(notification: notification)
        }
    }

    var selectedStep = 0
    var name = ""
    var notificationDescription = ""
    var noCondition = false
    var rules: [EditableLeaf] = []
    var advancedCondition: NotificationConditionNode?
    var count = 3
    var windowSecondsText = "10"
    var message = ""

    var windowValid: Bool {
        guard let seconds = Int(windowSecondsText.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            return false
        }
        return (10...86400).contains(seconds)
    }

    var parsedWindowSeconds: Int {
        Int(windowSecondsText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 10
    }
    var channels: [UserNotificationChannel] = []
    var selectedChannelIds: Set<Int> = []
    var filterOptions = NotificationFilterOptions()
    var isSaving = false
    var saveError = false
    var loadError = false

    func load(notification: UserNotification) {
        name = notification.name
        notificationDescription = notification.description ?? ""
        if case .and(let items) = notification.condition, items.isEmpty {
            noCondition = true
            self.rules = []
            advancedCondition = nil
        } else if let rules = Self.rules(from: notification.condition) {
            noCondition = false
            self.rules = rules
            advancedCondition = nil
        } else {
            noCondition = false
            self.rules = []
            advancedCondition = notification.condition
        }
        if let threshold = notification.threshold {
            count = threshold.count
            windowSecondsText = String(threshold.windowSeconds)
        }
        message = notification.message
        selectedChannelIds = Set(notification.channelIds)
    }

    func loadOptions() async {
        guard let apiClient = activeServerRepository.apiClient else { return }
        do {
            let alerts = try await apiClient.alerts.fetchAlerts(requestParams: AlertsRequest(
                filters: AlertsRequestFilters(countries: [], scenarios: [], ipOwners: [], targets: []),
                pagination: AlertsRequestPagination(offset: 0, limit: 1)
            ))
            let channels = try await apiClient.notificationChannels.fetchChannels()
            filterOptions = NotificationFilterOptions(
                scenarios: alerts.body.filtering.scenarios.sorted(),
                countries: alerts.body.filtering.countries.sorted(),
                targets: alerts.body.filtering.targets.sorted(),
                ipOwners: alerts.body.filtering.ipOwners.sorted()
            )
            self.channels = channels.body.data
        } catch {
            guard !(error is CancellationError) else { return }
            loadError = true
        }
    }

    func buildCondition() -> EditableCondition {
        if noCondition {
            return .and([])
        }
        return .and(rules.map(EditableCondition.leaf))
    }

    func replaceWithSimpleRules() {
        advancedCondition = nil
        rules = []
    }

    /// Fresh draft with the first available scenario already selected, so the
    /// displayed value and the model agree from the start.
    func newDraft() -> EditableLeaf {
        if let first = filterOptions.scenarios.first {
            return EditableLeaf(field: .scenario, op: .equals, values: [first])
        }
        return .empty
    }

    func validationIssue(step: Int) -> RulesValidationIssue? {
        guard step == 1 else { return nil }
        if !noCondition {
            if advancedCondition != nil {
                return .advanced
            }
            if rules.isEmpty {
                return .empty
            }
            if rules.contains(where: { !$0.isValid }) {
                return .incomplete
            }
        }
        if !windowValid {
            return .invalidWindow
        }
        return nil
    }

    func options(for field: ConditionField) -> [String] {
        switch field {
        case .scenario:
            return filterOptions.scenarios
        case .country:
            return filterOptions.countries
        case .target:
            return filterOptions.targets
        case .ipOwner:
            return filterOptions.ipOwners
        }
    }

    func canProceed(step: Int) -> Bool {
        switch step {
        case 0:
            return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 1:
            return validationIssue(step: 1) == nil
        case 2:
            return !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 3:
            return !selectedChannelIds.isEmpty
        default:
            return true
        }
    }

    func save() async -> UserNotification? {
        guard let apiClient = activeServerRepository.apiClient else { return nil }
        isSaving = true
        defer { isSaving = false }
        do {
            let threshold = NotificationThreshold(count: count, windowSeconds: parsedWindowSeconds)
            if let editing {
                let body = UpdateNotificationRequest(
                    name: name, description: descriptionOrNil(),
                    enabled: nil, condition: buildCondition().toAPI(),
                    threshold: threshold, message: message,
                    channelIds: Array(selectedChannelIds)
                )
                let response = try await apiClient.notifications.updateNotification(
                    notificationId: editing.id, body: body
                )
                return response.body.data
            } else {
                let body = CreateNotificationRequest(
                    name: name, description: descriptionOrNil(),
                    enabled: true, condition: buildCondition().toAPI(),
                    threshold: threshold, message: message,
                    channelIds: Array(selectedChannelIds)
                )
                let response = try await apiClient.notifications.createNotification(body: body)
                return response.body.data
            }
        } catch {
            guard !(error is CancellationError) else { return nil }
            saveError = true
            return nil
        }
    }

    /// Converts an API tree into flat rules when possible (AND of leaves, single
    /// leaf, or OR of same-field equals/in leaves merged into one rule).
    /// Returns nil for anything else (nested groups, cross-field OR, NOT).
    static func rules(from node: NotificationConditionNode) -> [EditableLeaf]? {
        switch node {
        case .leaf(let field, let op, let value):
            guard let leaf = editableLeaf(field: field, op: op, value: value) else { return nil }
            return [leaf]
        case .and(let items):
            var leaves: [EditableLeaf] = []
            for item in items {
                guard case .leaf(let field, let op, let value) = item else { return nil }
                guard let leaf = editableLeaf(field: field, op: op, value: value) else { return nil }
                leaves.append(leaf)
            }
            return leaves
        case .or(let items):
            return mergedOrRule(items)
        case .not:
            return nil
        }
    }

    private static func editableLeaf(field: String, op: String, value: NotificationConditionValue) -> EditableLeaf? {
        guard let f = ConditionField(rawValue: field), let o = ConditionOperator(rawValue: op) else { return nil }
        let values = value.asArray
        guard !values.isEmpty else { return nil }
        return EditableLeaf(field: f, op: o, values: values)
    }

    private static func mergedOrRule(_ items: [NotificationConditionNode]) -> [EditableLeaf]? {
        var field: ConditionField?
        var values: [String] = []
        for item in items {
            guard case .leaf(let f, let o, let v) = item else { return nil }
            guard o == ConditionOperator.equals.rawValue || o == ConditionOperator.in.rawValue else { return nil }
            guard let parsed = ConditionField(rawValue: f) else { return nil }
            if let field, field != parsed {
                return nil
            }
            field = parsed
            values.append(contentsOf: v.asArray)
        }
        guard let field, !values.isEmpty else { return nil }
        var seen: [String] = []
        for value in values where !seen.contains(value) {
            seen.append(value)
        }
        return [EditableLeaf(field: field, op: .in, values: seen)]
    }

    private func descriptionOrNil() -> String? {
        let trimmed = notificationDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
