import Foundation

// MARK: - Channel type

enum NotificationChannelType: String, Codable, Hashable, Sendable, CaseIterable {
    case ntfy
    case email
}

// MARK: - Provider configs (flat, all-optional; nils are omitted on encode)

struct NotificationChannelConfig: Codable, Hashable, Sendable {
    var server: String?
    var topic: String?
    var username: String?
    var password: String?
    var accessToken: String?
    var priority: String?
    var tags: String?
    var host: String?
    var port: Int?
    var secure: Bool?
    var from: String?
    var to: String?

    enum CodingKeys: String, CodingKey {
        case server, topic, username, password, accessToken, priority, tags
        case host, port, secure, from, to
    }

    init(
        server: String? = nil,
        topic: String? = nil,
        username: String? = nil,
        password: String? = nil,
        accessToken: String? = nil,
        priority: String? = nil,
        tags: String? = nil,
        host: String? = nil,
        port: Int? = nil,
        secure: Bool? = nil,
        from: String? = nil,
        to: String? = nil
    ) {
        self.server = server
        self.topic = topic
        self.username = username
        self.password = password
        self.accessToken = accessToken
        self.priority = priority
        self.tags = tags
        self.host = host
        self.port = port
        self.secure = secure
        self.from = from
        self.to = to
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        server = try container.decodeIfPresent(String.self, forKey: .server)
        topic = try container.decodeIfPresent(String.self, forKey: .topic)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        password = try container.decodeIfPresent(String.self, forKey: .password)
        accessToken = try container.decodeIfPresent(String.self, forKey: .accessToken)
        priority = try container.decodeIfPresent(String.self, forKey: .priority)
        tags = try container.decodeIfPresent(String.self, forKey: .tags)
        host = try container.decodeIfPresent(String.self, forKey: .host)
        port = try container.decodeIfPresent(Int.self, forKey: .port)
        secure = try container.decodeIfPresent(Bool.self, forKey: .secure)
        from = try container.decodeIfPresent(String.self, forKey: .from)
        to = try container.decodeIfPresent(String.self, forKey: .to)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(server, forKey: .server)
        try container.encodeIfPresent(topic, forKey: .topic)
        try container.encodeIfPresent(username, forKey: .username)
        try container.encodeIfPresent(password, forKey: .password)
        try container.encodeIfPresent(accessToken, forKey: .accessToken)
        try container.encodeIfPresent(priority, forKey: .priority)
        try container.encodeIfPresent(tags, forKey: .tags)
        try container.encodeIfPresent(host, forKey: .host)
        try container.encodeIfPresent(port, forKey: .port)
        try container.encodeIfPresent(secure, forKey: .secure)
        try container.encodeIfPresent(from, forKey: .from)
        try container.encodeIfPresent(to, forKey: .to)
    }
}

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
    var type: NotificationChannelType
    var config: NotificationChannelConfig
}

struct UpdateChannelRequest: Encodable, Sendable {
    var name: String?
    var type: NotificationChannelType?
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
    var type: NotificationChannelType
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
