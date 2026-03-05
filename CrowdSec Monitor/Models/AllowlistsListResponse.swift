import Foundation

// MARK: - AllowlistsListResponse
struct AllowlistsListResponse: Codable, Hashable {
    let data: [AllowlistsListResponse_Allowlist]
    let length: Int
}

// MARK: - AllowlistsListResponse_Allowlist
struct AllowlistsListResponse_Allowlist: Codable, Hashable {
    let createdAt, description: String
    let items: [AllowlistsListResponse_Allowlist_Item]
    let name, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case description, items, name
        case updatedAt = "updated_at"
    }
}

// MARK: - AllowlistsListResponse_Allowlist_Item
struct AllowlistsListResponse_Allowlist_Item: Codable, Hashable {
    let createdAt: String
    let expiration: String?
    let value: String

    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case expiration, value
    }
}
