import Foundation

// MARK: - StatisticsResponse
struct StatisticsResponse: Codable, Hashable {
    let alertsLast24Hours, activeDecisions: Int
    let activityHistory: [ActivityHistory]
    let topCountries: [TopCountry]
    let topScenarios: [TopScenario]
    let topIpOwners: [TopIPOwner]
    let topTargets: [TopTarget]
}

// MARK: - ActivityHistory
struct ActivityHistory: Codable, Identifiable, Hashable {
    var id: String { date }
    let date: String
    let amountAlerts, amountDecisions: Int
}

// MARK: - TopCountry
struct TopCountry: Codable, Identifiable, Hashable {
    var id: String { countryCode }
    let countryCode: String
    let amount: Int
}

// MARK: - TopIPOwner
struct TopIPOwner: Codable, Identifiable, Hashable {
    var id: String { ipOwner }
    let ipOwner: String
    let amount: Int
}

// MARK: - TopScenario
struct TopScenario: Codable, Identifiable, Hashable {
    var id: String { scenario }
    let scenario: String
    let amount: Int
}

// MARK: - TopTarget
struct TopTarget: Codable, Identifiable, Hashable {
    var id: String { target }
    let target: String
    let amount: Int
}
