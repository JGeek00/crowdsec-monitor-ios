import Foundation

// MARK: - AlertDetailsResponse
struct AlertDetailsResponse: Codable, Hashable {
    let id: Int
    let uuid, scenario, scenarioVersion, scenarioHash: String
    let message: String
    let capacity: Int
    let leakspeed: String
    let simulated, remediation: Bool
    let eventsCount: Int
    let machineID: String
    let source: Source
    let meta: [AlertDetailsMeta]
    let events: [Event]
    let crowdsecCreatedAt, startAt, stopAt: Date
    let decisions: [AlertDetailsDecision]

    enum CodingKeys: String, CodingKey {
        case id, uuid, scenario
        case scenarioVersion = "scenario_version"
        case scenarioHash = "scenario_hash"
        case message, capacity, leakspeed, simulated, remediation
        case eventsCount = "events_count"
        case machineID = "machine_id"
        case source, meta, events
        case crowdsecCreatedAt = "crowdsec_created_at"
        case startAt = "start_at"
        case stopAt = "stop_at"
        case decisions
    }
}

// MARK: - Decision
struct AlertDetailsDecision: Codable, Hashable {
    let id, alertID: Int
    let origin, type, scope, value: String
    let expiration: Date
    let scenario: String
    let simulated: Bool
    let source: Source
    let crowdsecCreatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case alertID = "alert_id"
        case origin, type, scope, value, expiration, scenario, simulated, source
        case crowdsecCreatedAt = "crowdsec_created_at"
    }
}

// MARK: - AlertDetailsSource
struct AlertDetailsSource: Codable, Hashable {
    let asName, asNumber, cn, ip: String
    let latitude, longitude: Double
    let range, scope, value: String

    enum CodingKeys: String, CodingKey {
        case asName = "as_name"
        case asNumber = "as_number"
        case cn, ip, latitude, longitude, range, scope, value
    }
}

// MARK: - AlertDetailsEvent
struct AlertDetailsEvent: Codable, Hashable {
    let meta: [AlertDetailsMeta]
    let timestamp: Date
}

// MARK: - AlertDetailsMeta
struct AlertDetailsMeta: Codable, Hashable {
    let key, value: String
}
