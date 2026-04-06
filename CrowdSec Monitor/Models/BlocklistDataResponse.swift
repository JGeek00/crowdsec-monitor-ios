import Foundation

// MARK: - BlocklistDataResponse
struct BlocklistDataResponse: Codable {
    let data: BlocklistDataResponse_Data
}

// MARK: - BlocklistDataResponse_Data
struct BlocklistDataResponse_Data: Codable {
    let id: String
    let url: String?
    let name: String
    let enabled: Bool?
    let addedDate, lastRefreshAttempt, lastSuccessfulRefresh: String?
    let countIPS: Int
    let type: BlocklistDataResponse_Data_Type
    let blocklistIPS: [String]

    enum CodingKeys: String, CodingKey {
        case id, url, name, enabled
        case addedDate = "added_date"
        case lastRefreshAttempt = "last_refresh_attempt"
        case lastSuccessfulRefresh = "last_successful_refresh"
        case countIPS = "count_ips"
        case type
        case blocklistIPS = "blocklistIps"
    }
}

// MARK: - BlocklistDataResponse_Data_Type
enum BlocklistDataResponse_Data_Type: String, Codable {
    case api = "api"
    case crowdsec = "cs"
}
