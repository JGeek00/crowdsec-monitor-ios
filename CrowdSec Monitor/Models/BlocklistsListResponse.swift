import Foundation

// MARK: - BlocklistsListResponse
struct BlocklistsListResponse: Codable, Hashable {
    let items: [BlocklistsListResponse_Item]
    let pagination: BlocklistsListResponse_Pagination
}

// MARK: - BlocklistsListResponse_Item
struct BlocklistsListResponse_Item: Codable, Hashable {
    let id: Int
    let url: String?
    let name: String
    let enabled: Bool?
    let addedDate, lastRefreshAttempt, lastSuccessfulRefresh: String?
    let countIPS: Int
    let type: BlocklistsListResponse_Item_Type

    enum CodingKeys: String, CodingKey {
        case id, url, name, enabled
        case addedDate = "added_date"
        case lastRefreshAttempt = "last_refresh_attempt"
        case lastSuccessfulRefresh = "last_successful_refresh"
        case countIPS = "count_ips"
        case type
    }
}

// MARK: - BlocklistsListResponse_Item_Type
enum BlocklistsListResponse_Item_Type: String, Codable, Hashable {
    case api = "api"
    case crowdsec = "cs"
}

// MARK: - Pagination
struct BlocklistsListResponse_Pagination: Codable, Hashable {
    let page, amount, total: Int
}
