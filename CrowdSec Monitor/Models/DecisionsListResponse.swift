import Foundation

// MARK: - DecisionsListResponse
struct DecisionsListResponse: Codable, Hashable, Equatable {
    let filtering: DecisionsListResponse_Filtering
    let items: [DecisionsListResponse_Item]
    let pagination: DecisionsListResponse_Pagination
}

// MARK: - Filtering
struct DecisionsListResponse_Filtering: Codable, Hashable, Equatable {
    let countries, ipOwners: [String]
}

// MARK: - DecisionItem
struct DecisionsListResponse_Item: Codable, Hashable, Equatable {
    let id, alertId: Int
    let origin: String
    let type: String
    let scope: String
    let value, expiration, scenario: String
    let simulated: Bool
    let source: DecisionsListResponse_Item_Source
    let crowdsecCreatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case alertId = "alert_id"
        case origin, type, scope, value, expiration, scenario, simulated, source
        case crowdsecCreatedAt = "crowdsec_created_at"
    }
}

// MARK: - DecisionsListResponse_Item_Source
struct DecisionsListResponse_Item_Source: Codable, Hashable, Equatable {
    let asName: String?
    let asNumber, cn, ip: String?
    let latitude, longitude: Double?
    let range: String?
    let scope: String
    let value: String

    enum CodingKeys: String, CodingKey {
        case asName = "as_name"
        case asNumber = "as_number"
        case cn, ip, latitude, longitude, range, scope, value
    }
}

// MARK: - Pagination
struct DecisionsListResponse_Pagination: Codable, Hashable, Equatable {
    let page, amount, total: Int
}
