import Foundation

// MARK: - DecisionsByIPResponse
struct DecisionsByIPResponse: Codable, Hashable, Sendable {
    let filtering: DecisionsListResponse_Filtering
    let groups: [DecisionsByIPResponse_Group]
    let pagination: DecisionsListResponse_Pagination
}

// MARK: - DecisionsByIPResponse_Group
struct DecisionsByIPResponse_Group: Codable, Hashable, Sendable {
    let ip: String
    let country: String
    let owner: String
    let asNumber: String
    let latitude: Double
    let longitude: Double
    let range: String
    let activeDecisions: Int
    let totalDecisions: Int

    enum CodingKeys: String, CodingKey {
        case ip, country, owner, latitude, longitude, range
        case asNumber = "as_number"
        case activeDecisions = "active_decisions"
        case totalDecisions = "total_decisions"
    }
}
