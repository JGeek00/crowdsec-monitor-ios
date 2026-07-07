import Foundation

// MARK: - AllowlistsListResponse
nonisolated struct AllowlistsListResponse: Codable, Hashable, Sendable {
    let data: [AllowlistsListResponse_Allowlist]
    let length: Int
}

// MARK: - AllowlistsListResponse_Allowlist
nonisolated struct AllowlistsListResponse_Allowlist: Codable, Hashable, Sendable {
    let createdAt, description: String
    let items: [AllowlistsListResponse_Allowlist_Item]
    let name, updatedAt: String

nonisolated     enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case description, items, name
        case updatedAt = "updated_at"
    }
}

// MARK: - AllowlistsListResponse_Allowlist_Item
nonisolated struct AllowlistsListResponse_Allowlist_Item: Codable, Hashable, Sendable {
    let createdAt: String
    let expiration: String?
    let value: String

nonisolated     enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case expiration, value
    }
}
