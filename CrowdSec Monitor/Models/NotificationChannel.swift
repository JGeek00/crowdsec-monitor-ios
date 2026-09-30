import Foundation

// MARK: - Channel type (built-in providers)

enum NotificationChannelType: String, Codable, Hashable, Sendable, CaseIterable {
    case ntfy
    case email
}

// MARK: - Channel config

/// Dynamic config; unknown future fields survive round-trips.
typealias NotificationChannelConfig = [String: JSONValue]


// MARK: - Channel

struct UserNotificationChannel: Codable, Hashable, Sendable, Identifiable {
    let id: Int
    let name: String
    let type: NotificationChannelType
    let config: NotificationChannelConfig
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, type, config
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Responses

struct NotificationChannelsListResponse: Codable, Hashable, Sendable {
    let data: [UserNotificationChannel]
}

struct NotificationChannelDetailResponse: Codable, Hashable, Sendable {
    let data: UserNotificationChannel
}

struct DeleteNotificationChannelResponse: Codable, Hashable, Sendable {
    let message: String
}

struct ChannelTestResult: Codable, Hashable, Sendable {
    let channelId: Int?
    let ok: Bool
    let detail: String?
}

struct ChannelTestResponse: Codable, Hashable, Sendable {
    let data: ChannelTestResult
}

// MARK: - Request bodies

struct CreateChannelRequest: Encodable, Sendable {
    var name: String
    var type: String
    var config: NotificationChannelConfig
}

struct UpdateChannelRequest: Encodable, Sendable {
    var name: String?
    var type: String?
    var config: NotificationChannelConfig?

    enum CodingKeys: String, CodingKey {
        case name, type, config
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(config, forKey: .config)
    }
}

struct TestChannelRequest: Encodable, Sendable {
    var message: String?

    enum CodingKeys: String, CodingKey {
        case message
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(message, forKey: .message)
    }
}

struct TestInlineChannelRequest: Encodable, Sendable {
    var type: String
    var config: NotificationChannelConfig
    var message: String?

    enum CodingKeys: String, CodingKey {
        case type, config, message
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(config, forKey: .config)
        try container.encodeIfPresent(message, forKey: .message)
    }
}
