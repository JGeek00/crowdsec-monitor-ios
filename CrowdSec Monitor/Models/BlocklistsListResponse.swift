import Foundation

// MARK: - BlocklistsListResponse
struct BlocklistsListResponse: Codable, Hashable, Equatable {
    let items: [BlocklistsListResponse_Blocklist]
    let pagination: BlocklistsListResponse_Pagination
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

// MARK: - BlocklistsListResponse_Pagination
struct BlocklistsListResponse_Pagination: Codable, Hashable {
    let page, amount, total: Int
}

