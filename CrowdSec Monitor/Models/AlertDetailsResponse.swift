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
    let source: AlertDetailsResponse_Source
    let meta: [AlertDetailsResponse_Meta]
    let events: [AlertDetailsResponse_Event]
    let crowdsecCreatedAt, startAt, stopAt: Date
    let decisions: [AlertDetailsResponse_Decision]

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

// MARK: - AlertDetailsResponse_Meta
struct AlertDetailsResponse_Meta: Codable, Hashable {
    let key: String
    let value: String
}

// MARK: - AlertDetailsResponse_Decision
struct AlertDetailsResponse_Decision: Codable, Hashable {
    let id, alertID: Int
    let origin, type, scope, value: String
    let expiration: Date
    let scenario: String
    let simulated: Bool
    let source: AlertDetailsResponse_Source
    let crowdsecCreatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case alertID = "alert_id"
        case origin, type, scope, value, expiration, scenario, simulated, source
        case crowdsecCreatedAt = "crowdsec_created_at"
    }
}

// MARK: - AlertDetailsResponse_Source
struct AlertDetailsResponse_Source: Codable, Hashable {
    let asName, asNumber, cn, ip: String
    let latitude, longitude: Double
    let range, scope, value: String

    enum CodingKeys: String, CodingKey {
        case asName = "as_name"
        case asNumber = "as_number"
        case cn, ip, latitude, longitude, range, scope, value
    }
}

// MARK: - AlertDetailsResponse_Event
struct AlertDetailsResponse_Event: Codable, Hashable {
    let meta: [AlertDetailsResponse_Event_Meta]
    let timestamp: Date
}

// MARK: - AlertDetailsResponse_Event_Meta
struct AlertDetailsResponse_Event_Meta: Codable, Hashable {
    let key, value: String
}
