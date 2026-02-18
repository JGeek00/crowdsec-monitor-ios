import Foundation

// MARK: - DecisionItemResponse
struct DecisionItemResponse: Codable, Hashable {
    let id, alertId: Int
    let origin, type, scope, value: String
    let expiration, scenario: String
    let simulated: Bool
    let source: DecisionItemResponse_Source
    let crowdsecCreatedAt: String
    let alert: DecisionItemResponse_Alert

    enum CodingKeys: String, CodingKey {
        case id
        case alertId = "alert_id"
        case origin, type, scope, value, expiration, scenario, simulated, source
        case crowdsecCreatedAt = "crowdsec_created_at"
        case alert
    }
}

// MARK: - DecisionItemResponse_Alert
struct DecisionItemResponse_Alert: Codable, Hashable {
    let id: Int
    let uuid, scenario, scenarioVersion, scenarioHash: String
    let message: String
    let capacity: Int
    let leakspeed: String
    let simulated, remediation: Bool
    let eventsCount: Int
    let machineId: String
    let source: DecisionItemResponse_Source
    let meta: [DecisionItemResponse_Alert_Meta]
    let events: [DecisionItemResponse_Alert_Event]
    let crowdsecCreatedAt, startAt, stopAt: String

    enum CodingKeys: String, CodingKey {
        case id, uuid, scenario
        case scenarioVersion = "scenario_version"
        case scenarioHash = "scenario_hash"
        case message, capacity, leakspeed, simulated, remediation
        case eventsCount = "events_count"
        case machineId = "machine_id"
        case source, meta, events
        case crowdsecCreatedAt = "crowdsec_created_at"
        case startAt = "start_at"
        case stopAt = "stop_at"
    }
}

// MARK: - DecisionItemResponse_Alert_Event
struct DecisionItemResponse_Alert_Event: Codable, Hashable {
    let meta: [DecisionItemResponse_Alert_Meta]
    let timestamp: String
}

// MARK: - DecisionItemResponse_Alert_Meta
struct DecisionItemResponse_Alert_Meta: Codable, Hashable {
    let key: String
    let value: [String]
}

// MARK: - DecisionItemResponse_Source
struct DecisionItemResponse_Source: Codable, Hashable {
    let asName, asNumber, cn, ip: String
    let latitude, longitude: Double
    let range, scope, value: String

    enum CodingKeys: String, CodingKey {
        case asName = "as_name"
        case asNumber = "as_number"
        case cn, ip, latitude, longitude, range, scope, value
    }
}

