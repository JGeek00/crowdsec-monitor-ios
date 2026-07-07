import Foundation

// MARK: - BlocklistsListResponse
nonisolated struct BlocklistsListResponse: Codable, Hashable, Sendable {
    let items: [BlocklistsListResponse_Item]
    let pagination: BlocklistsListResponse_Pagination
}

// MARK: - BlocklistsListResponse_Item
nonisolated struct BlocklistsListResponse_Item: Codable, Hashable, Sendable {
    let id: String
    let url: String?
    let name: String
    let enabled: Bool?
    let addedDate, lastRefreshAttempt, lastSuccessfulRefresh: String?
    let lastRefreshFailed: Bool?
    let countIPS: Int
    let type: BlocklistsListResponse_Item_Type

nonisolated     enum CodingKeys: String, CodingKey {
        case id, url, name, enabled
        case addedDate = "added_date"
        case lastRefreshAttempt = "last_refresh_attempt"
        case lastSuccessfulRefresh = "last_successful_refresh"
        case lastRefreshFailed = "last_refresh_failed"
        case countIPS = "count_ips"
        case type
    }
}

// MARK: - BlocklistsListResponse_Item_Type
nonisolated enum BlocklistsListResponse_Item_Type: String, Codable, Hashable, Sendable {
    case api = "api"
    case crowdsec = "cs"
}

// MARK: - Pagination
nonisolated struct BlocklistsListResponse_Pagination: Codable, Hashable, Sendable {
    let page, amount, total: Int
}
