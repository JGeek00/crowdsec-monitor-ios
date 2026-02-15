import Foundation

// MARK: - AlertsResponse
struct AlertsResponse: Codable, Hashable {
    let filtering: Filtering
    let items: [Alert]
    let pagination: Pagination
}

// MARK: - Filtering
struct Filtering: Codable, Hashable {
    let countries, scenarios, ipOwners, targets: [String]
}

// MARK: - Alert
struct Alert: Codable, Hashable {
    let id: Int
    let uuid, scenario, scenarioVersion, scenarioHash: String
    let message: String
    let capacity: Int
    let leakspeed: String
    let simulated, remediation: Bool
    let eventsCount: Int
    let machineID: String
    let source: Source
    let meta: [ItemMeta]
    let events: [Event]
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

// MARK: - Event
struct Event: Codable, Hashable {
    let meta: [EventMeta]
    let timestamp: String
}

// MARK: - EventMeta
struct EventMeta: Codable, Hashable {
    let key: PurpleKey
    let value: String
}

enum PurpleKey: String, Codable, Hashable {
    case asnNumber = "ASNNumber"
    case asnOrg = "ASNOrg"
    case datasourcePath = "datasource_path"
    case datasourceType = "datasource_type"
    case httpArgsLen = "http_args_len"
    case httpPath = "http_path"
    case httpStatus = "http_status"
    case httpUserAgent = "http_user_agent"
    case httpVerb = "http_verb"
    case isInEU = "IsInEU"
    case isoCode = "IsoCode"
    case logType = "log_type"
    case service = "service"
    case sourceIP = "source_ip"
    case sourceRange = "SourceRange"
    case targetFQDN = "target_fqdn"
    case timestamp = "timestamp"
}

// MARK: - ItemMeta
struct ItemMeta: Codable, Hashable {
    let key: FluffyKey
    let value: [String]
}

enum FluffyKey: String, Codable, Hashable {
    case method = "method"
    case status = "status"
    case targetURI = "target_uri"
    case userAgent = "user_agent"
}

// MARK: - Source
struct Source: Codable, Hashable {
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

// MARK: - Pagination
struct Pagination: Codable, Hashable {
    let page, amount, total: Int
}

