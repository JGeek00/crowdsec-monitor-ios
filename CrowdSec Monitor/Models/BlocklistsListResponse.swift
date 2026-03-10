import Foundation

// MARK: - BlocklistsListResponse
struct BlocklistsListResponse: Codable, Hashable, Equatable {
    let data: [BlocklistsListResponse_Blocklist]
    let total, limit, offset: Int
}

// MARK: - BlocklistsListResponse_Blocklist
struct BlocklistsListResponse_Blocklist: Codable, Hashable, Equatable {
    let id: Int
    let name: String
    let countIPS: Int

    enum CodingKeys: String, CodingKey {
        case id, name
        case countIPS = "count_ips"
    }
}
