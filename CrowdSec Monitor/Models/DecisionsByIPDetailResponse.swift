import Foundation

// MARK: - DecisionsByIPDetailResponse
struct DecisionsByIPDetailResponse: Codable, Hashable, Sendable {
    let ip: String
    let country: String?
    let owner: String?
    let asNumber: String?
    let latitude: Double?
    let longitude: Double?
    let range: String?
    let activeDecisions: Int
    let totalDecisions: Int
    let decisions: [DecisionsByIPDetailResponse_Decision]

    enum CodingKeys: String, CodingKey {
        case ip, country, owner, latitude, longitude, range
        case asNumber = "as_number"
        case activeDecisions = "active_decisions"
        case totalDecisions = "total_decisions"
        case decisions
    }
}

// MARK: - DecisionsByIPDetailResponse_Decision
struct DecisionsByIPDetailResponse_Decision: Codable, Hashable, Sendable {
    let id: Int
    let alertId: Int?
    let origin: String
    let type: String
    let scope: String
    let value: String
    let expiration: String
    let scenario: String
    let simulated: Bool
    let crowdsecCreatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case alertId = "alert_id"
        case origin, type, scope, value, expiration, scenario, simulated
        case crowdsecCreatedAt = "crowdsec_created_at"
    }
}
