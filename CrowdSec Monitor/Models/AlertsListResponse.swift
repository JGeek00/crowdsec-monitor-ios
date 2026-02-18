import Foundation

// MARK: - AlertsListResponse
struct AlertsListResponse: Codable, Hashable {
    let filtering: AlertsListResponse_Filtering
    let items: [AlertsListResponse_Alert]
    let pagination: AlertsListResponse_Pagination
}

// MARK: - Filtering
struct AlertsListResponse_Filtering: Codable, Hashable {
    let countries, scenarios, ipOwners, targets: [String]
}

// MARK: - AlertsListResponse_Alert
struct AlertsListResponse_Alert: Codable, Hashable {
    let id: Int
    let uuid, scenario, scenarioVersion, scenarioHash: String
    let message: String
    let capacity: Int
    let leakspeed: String
    let simulated, remediation: Bool
    let eventsCount: Int
    let machineID: String
    let source: AlertsListResponse_Alert_Source
    let meta: [AlertsListResponse_ItemMeta]
    let events: [AlertsListResponse_Event]
    let crowdsecCreatedAt, startAt, stopAt: String

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
    }
}

// MARK: - AlertsListResponse_ItemMeta
struct AlertsListResponse_ItemMeta: Codable, Hashable {
    let key: String
    let value: [String]
}

// MARK: - AlertsListResponse_Event
struct AlertsListResponse_Event: Codable, Hashable {
    let meta: [AlertsListResponse_Event_EventMeta]
    let timestamp: String
}

// MARK: - AlertsListResponse_Event_EventMeta
struct AlertsListResponse_Event_EventMeta: Codable, Hashable {
    let key: String
    let value: [String]
}

// MARK: - AlertsListResponse_Alert_Source
struct AlertsListResponse_Alert_Source: Codable, Hashable {
    let asName: String?
    let asNumber, cn, ip: String
    let latitude, longitude: Double
    let range: String?
    let scope: String
    let value: String

    enum CodingKeys: String, CodingKey {
        case asName = "as_name"
        case asNumber = "as_number"
        case cn, ip, latitude, longitude, range, scope, value
    }
}

// MARK: - AlertsListResponse_Pagination
struct AlertsListResponse_Pagination: Codable, Hashable {
    let page, amount, total: Int
}

