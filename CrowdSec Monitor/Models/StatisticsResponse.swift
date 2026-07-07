import Foundation

// MARK: - StatisticsResponse
nonisolated struct StatisticsResponse: Codable, Hashable, Sendable {
    let alertsLast24Hours, activeDecisions: Int
    let activityHistory: [ActivityHistory]
    let topCountries: [TopCountry]
    let topScenarios: [TopScenario]
    let topIpOwners: [TopIPOwner]
    let topTargets: [TopTarget]
}

// MARK: - ActivityHistory
nonisolated struct ActivityHistory: Codable, Identifiable, Hashable {
    var id: String { date }
    let date: String
    let amountAlerts, amountDecisions: Int
}

// MARK: - TopCountry
nonisolated struct TopCountry: Codable, Identifiable, Hashable {
    var id: String { countryCode }
    let countryCode: String
    let amount: Int
}

// MARK: - TopIPOwner
nonisolated struct TopIPOwner: Codable, Identifiable, Hashable {
    var id: String { ipOwner }
    let ipOwner: String
    let amount: Int
}

// MARK: - TopScenario
nonisolated struct TopScenario: Codable, Identifiable, Hashable {
    var id: String { scenario }
    let scenario: String
    let amount: Int
}

// MARK: - TopTarget
nonisolated struct TopTarget: Codable, Identifiable, Hashable {
    var id: String { target }
    let target: String
    let amount: Int
}
