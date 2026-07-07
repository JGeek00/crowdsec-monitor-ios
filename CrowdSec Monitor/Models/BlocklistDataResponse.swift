import Foundation

// MARK: - BlocklistDataResponse
nonisolated struct BlocklistDataResponse: Codable {
    let data: BlocklistDataResponse_Data
}

// MARK: - BlocklistDataResponse_Data
nonisolated struct BlocklistDataResponse_Data: Codable {
    let id: String
    let url: String?
    let name: String
    let enabled: Bool?
    let addedDate, lastRefreshAttempt, lastSuccessfulRefresh: String?
    let lastRefreshFailed: Bool?
    let countIPS: Int
    let type: BlocklistDataResponse_Data_Type
    let blocklistIPS: [String]

nonisolated     enum CodingKeys: String, CodingKey {
        case id, url, name, enabled
        case addedDate = "added_date"
        case lastRefreshAttempt = "last_refresh_attempt"
        case lastSuccessfulRefresh = "last_successful_refresh"
        case lastRefreshFailed = "last_refresh_failed"
        case countIPS = "count_ips"
        case type
        case blocklistIPS = "blocklistIps"
    }
}

// MARK: - BlocklistDataResponse_Data_Type
nonisolated enum BlocklistDataResponse_Data_Type: String, Codable {
    case api = "api"
    case crowdsec = "cs"
}
