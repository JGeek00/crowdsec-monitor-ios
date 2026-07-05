import Foundation

// MARK: - APIStatusResponse
struct APIStatusResponse: Codable, Hashable {
    let csLapi: APIStatusResponse_CSLapi
    let csBouncer: APIStatusResponse_CSBouncer
    let csMonitorAPI: APIStatusResponse_CSMonitorAPI
    let processes: [APIStatusResponse_Process]

    enum CodingKeys: String, CodingKey {
        case csLapi, csBouncer
        case csMonitorAPI = "csMonitorApi"
        case processes
    }
}

// MARK: - APIStatusResponse_CSBouncer
struct APIStatusResponse_CSBouncer: Codable, Hashable {
    let available: Bool
}

// MARK: - APIStatusResponse_CSLapi
struct APIStatusResponse_CSLapi: Codable, Hashable {
    let lapiConnected: Bool
    let lastSuccessfulSync, timestamp: String
}

// MARK: - APIStatusResponse_CSMonitorAPI
struct APIStatusResponse_CSMonitorAPI: Codable, Hashable {
    let version: String
    let newVersionAvailable: String?
}

// MARK: - Process
struct APIStatusResponse_Process: Codable, Hashable {
    let id: String
    let beginDatetime: String
    let endDatetime: String?
    let successful: Bool?
    let error: String?
    let blocklistImport: APIStatusResponse_ProcessBlocklist?
    let blocklistEnable: APIStatusResponse_ProcessBlocklist?
    let blocklistDisable: APIStatusResponse_ProcessBlocklistIps?
    let blocklistDelete: APIStatusResponse_ProcessBlocklistIps?
    let blocklistRefresh: APIStatusResponse_ProcessBlocklistRefresh?
    let blocklistSingleRefresh: APIStatusResponse_ProcessBlocklistSingleRefresh?
}

// MARK: - APIStatusResponse_ProcessBlocklistFieldStatus
enum APIStatusResponse_ProcessBlocklistFieldStatus: String, Codable, Hashable {
    case pending = "pending"
    case running = "running"
    case successful = "successful"
    case failed = "failed"
}

// MARK: - APIStatusResponse_ProcessBlocklistStep
enum APIStatusResponse_ProcessBlocklistStep: String, Codable, Hashable {
    case fetch = "fetch"
    case parse = "parse"
    case delete = "delete"
    case `import` = "import"
}

// MARK: - APIStatusResponse_ProcessBlocklistProgress
struct APIStatusResponse_ProcessBlocklistProgress: Codable, Hashable {
    let totalIps: Int
    let processedIps: Int
}

// MARK: - APIStatusResponse_ProcessBlocklistIps
struct APIStatusResponse_ProcessBlocklistIps: Codable, Hashable {
    let blocklistId: Int
    let blocklistName: String
    let blocklistIps: Int
    let ipsToDelete: Int
    let processedIps: Int
}

// MARK: - APIStatusResponse_ProcessBlocklist
struct APIStatusResponse_ProcessBlocklist: Codable, Hashable {
    let blocklistId: Int
    let blocklistName: String
    let step: APIStatusResponse_ProcessBlocklistStep
    let fetched: APIStatusResponse_ProcessBlocklistFieldStatus
    let parsed: APIStatusResponse_ProcessBlocklistFieldStatus
    let imported: APIStatusResponse_ProcessBlocklistFieldStatus
    let processIps: APIStatusResponse_ProcessBlocklistProgress
}

// MARK: - APIStatusResponse_ProcessBlocklistSingleRefresh
struct APIStatusResponse_ProcessBlocklistSingleRefresh: Codable, Hashable {
    let blocklistId: Int
    let blocklistName: String
    let step: APIStatusResponse_ProcessBlocklistStep
    let fetched: APIStatusResponse_ProcessBlocklistFieldStatus
    let parsed: APIStatusResponse_ProcessBlocklistFieldStatus
    let deleted: APIStatusResponse_ProcessBlocklistFieldStatus
    let imported: APIStatusResponse_ProcessBlocklistFieldStatus
    let processIps: APIStatusResponse_ProcessBlocklistProgress
}

// MARK: - APIStatusResponse_ProcessBlocklistRefresh
struct APIStatusResponse_ProcessBlocklistRefresh: Codable, Hashable {
    let totalBlocklists, currentBlocklist: Int
    let blocklists: [APIStatusResponse_ProcessBlocklistRefresh_Blocklist]
    let totalIPS: Int

    enum CodingKeys: String, CodingKey {
        case totalBlocklists, currentBlocklist, blocklists
        case totalIPS = "totalIps"
    }
}

// MARK: - APIStatusResponse_ProcessBlocklistRefresh_Blocklist
struct APIStatusResponse_ProcessBlocklistRefresh_Blocklist: Codable, Hashable {
    let number: Int
    let name: String
    let steps: APIStatusResponse_ProcessBlocklistRefresh_Blocklist_Steps
}

// MARK: - APIStatusResponse_ProcessBlocklistRefresh_Blocklist_Steps
struct APIStatusResponse_ProcessBlocklistRefresh_Blocklist_Steps: Codable, Hashable {
    let fetch: APIStatusResponse_ProcessBlocklistFieldStatus
    let parse: APIStatusResponse_ProcessBlocklistFieldStatus
    let delete: APIStatusResponse_ProcessBlocklistFieldStatus
    let `import`: APIStatusResponse_ProcessBlocklistFieldStatus
}

