import Foundation

// MARK: - Condition value (string or string array)

enum NotificationConditionValue: Hashable, Sendable {
    case single(String)
    case multiple([String])

    var asArray: [String] {
        switch self {
        case .single(let value):
            return [value]
        case .multiple(let values):
            return values
        }
    }
}

extension NotificationConditionValue: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let single = try? container.decode(String.self) {
            self = .single(single)
        } else {
            self = .multiple(try container.decode([String].self))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .single(let value):
            try container.encode(value)
        case .multiple(let values):
            try container.encode(values)
        }
    }
}

// MARK: - Condition node (recursive block tree)

indirect enum NotificationConditionNode: Hashable, Sendable {
    case leaf(field: String, op: String, value: NotificationConditionValue)
    case and([NotificationConditionNode])
    case or([NotificationConditionNode])
    case not(NotificationConditionNode)
}

extension NotificationConditionNode: Codable {
    private enum Keys: String, CodingKey {
        case type, field, value, children, child
        case op = "operator"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "leaf":
            self = .leaf(
                field: try container.decode(String.self, forKey: .field),
                op: try container.decode(String.self, forKey: .op),
                value: try container.decode(NotificationConditionValue.self, forKey: .value)
            )
        case "and":
            self = .and(try container.decode([NotificationConditionNode].self, forKey: .children))
        case "or":
            self = .or(try container.decode([NotificationConditionNode].self, forKey: .children))
        case "not":
            self = .not(try container.decode(NotificationConditionNode.self, forKey: .child))
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type, in: container, debugDescription: "Unknown condition type: \(type)"
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        switch self {
        case .leaf(let field, let op, let value):
            try container.encode("leaf", forKey: .type)
            try container.encode(field, forKey: .field)
            try container.encode(op, forKey: .op)
            try container.encode(value, forKey: .value)
        case .and(let children):
            try container.encode("and", forKey: .type)
            try container.encode(children, forKey: .children)
        case .or(let children):
            try container.encode("or", forKey: .type)
            try container.encode(children, forKey: .children)
        case .not(let child):
            try container.encode("not", forKey: .type)
            try container.encode(child, forKey: .child)
        }
    }
}

// MARK: - Threshold ("x times in y seconds")

struct NotificationThreshold: Codable, Hashable, Sendable {
    let count: Int
    let windowSeconds: Int

    enum CodingKeys: String, CodingKey {
        case count
        case windowSeconds
    }
}

// MARK: - User notification

struct UserNotification: Codable, Hashable, Sendable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let enabled: Bool
    let condition: NotificationConditionNode
    let threshold: NotificationThreshold?
    let message: String
    let channelIds: [Int]
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description, enabled, condition, threshold, message, channelIds
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - History

struct NotificationHistoryChannel: Codable, Hashable, Sendable {
    let type: String
    let ok: Bool
    let detail: String?
}

struct NotificationHistoryEntry: Codable, Hashable, Sendable, Identifiable {
    let id: String
    let notificationId: Int
    let notificationName: String
    let message: String
    let triggeredAt: String
    let channels: [NotificationHistoryChannel]
}

// MARK: - Responses

struct NotificationsListResponse: Codable, Hashable, Sendable {
    let data: [UserNotification]
}

struct NotificationDetailResponse: Codable, Hashable, Sendable {
    let data: UserNotification
}

struct NotificationHistoryResponse: Codable, Hashable, Sendable {
    let data: [NotificationHistoryEntry]
    let total: Int
}

struct DeleteNotificationResponse: Codable, Hashable, Sendable {
    let message: String
}

// MARK: - Request bodies (nil fields are omitted so backend defaults apply)

struct CreateNotificationRequest: Encodable, Sendable {
    var name: String
    var description: String?
    var enabled: Bool?
    var condition: NotificationConditionNode
    var threshold: NotificationThreshold?
    var message: String
    var channelIds: [Int]

    enum CodingKeys: String, CodingKey {
        case name, description, enabled, condition, threshold, message, channelIds
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(enabled, forKey: .enabled)
        try container.encode(condition, forKey: .condition)
        try container.encodeIfPresent(threshold, forKey: .threshold)
        try container.encode(message, forKey: .message)
        try container.encode(channelIds, forKey: .channelIds)
    }
}

struct UpdateNotificationRequest: Encodable, Sendable {
    var name: String?
    var description: String?
    var enabled: Bool?
    var condition: NotificationConditionNode?
    var threshold: NotificationThreshold?
    var message: String?
    var channelIds: [Int]?

    enum CodingKeys: String, CodingKey {
        case name, description, enabled, condition, threshold, message, channelIds
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(enabled, forKey: .enabled)
        try container.encodeIfPresent(condition, forKey: .condition)
        try container.encodeIfPresent(threshold, forKey: .threshold)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(channelIds, forKey: .channelIds)
    }
}

struct ToggleNotificationRequest: Codable, Sendable {
    let enabled: Bool
}
