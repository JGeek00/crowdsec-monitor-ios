import Foundation

// MARK: - APIStatusResponse
nonisolated struct APIStatusResponse: Codable, Hashable, Sendable, Sendable {
    let csLapi: APIStatusResponse_CSLapi
    let csBouncer: APIStatusResponse_CSBouncer
    let csMonitorAPI: APIStatusResponse_CSMonitorAPI
    let processes: [APIStatusResponse_Process]

nonisolated     enum CodingKeys: String, CodingKey {
        case csLapi, csBouncer
        case csMonitorAPI = "csMonitorApi"
        case processes
    }
}

// MARK: - APIStatusResponse_CSBouncer
nonisolated struct APIStatusResponse_CSBouncer: Codable, Hashable, Sendable {
    let available: Bool
}

// MARK: - APIStatusResponse_CSLapi
nonisolated struct APIStatusResponse_CSLapi: Codable, Hashable, Sendable {
    let lapiConnected: Bool
    let lastSuccessfulSync, timestamp: String
}

// MARK: - APIStatusResponse_CSMonitorAPI
nonisolated struct APIStatusResponse_CSMonitorAPI: Codable, Hashable, Sendable {
    let version: String
    let newVersionAvailable: String?
}

// MARK: - Process
nonisolated struct APIStatusResponse_Process: Codable, Hashable, Sendable {
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
nonisolated enum APIStatusResponse_ProcessBlocklistFieldStatus: String, Codable, Hashable, Sendable {
    case pending = "pending"
    case running = "running"
    case successful = "successful"
    case failed = "failed"
}

// MARK: - APIStatusResponse_ProcessBlocklistStep
nonisolated enum APIStatusResponse_ProcessBlocklistStep: String, Codable, Hashable, Sendable {
    case fetch = "fetch"
    case parse = "parse"
    case delete = "delete"
    case `import` = "import"
}

// MARK: - APIStatusResponse_ProcessBlocklistProgress
nonisolated struct APIStatusResponse_ProcessBlocklistProgress: Codable, Hashable, Sendable {
    let totalIps: Int
    let processedIps: Int
}

// MARK: - APIStatusResponse_ProcessBlocklistIps
nonisolated struct APIStatusResponse_ProcessBlocklistIps: Codable, Hashable, Sendable {
    let blocklistId: Int
    let blocklistName: String
    let blocklistIps: Int
    let ipsToDelete: Int
    let processedIps: Int
}

// MARK: - APIStatusResponse_ProcessBlocklist
nonisolated struct APIStatusResponse_ProcessBlocklist: Codable, Hashable, Sendable {
    let blocklistId: Int
    let blocklistName: String
    let step: APIStatusResponse_ProcessBlocklistStep
    let fetched: APIStatusResponse_ProcessBlocklistFieldStatus
    let parsed: APIStatusResponse_ProcessBlocklistFieldStatus
    let imported: APIStatusResponse_ProcessBlocklistFieldStatus
    let processIps: APIStatusResponse_ProcessBlocklistProgress
}

// MARK: - APIStatusResponse_ProcessBlocklistSingleRefresh
nonisolated struct APIStatusResponse_ProcessBlocklistSingleRefresh: Codable, Hashable, Sendable {
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
nonisolated struct APIStatusResponse_ProcessBlocklistRefresh: Codable, Hashable, Sendable {
    let totalBlocklists, currentBlocklist: Int
    let blocklists: [APIStatusResponse_ProcessBlocklistRefresh_Blocklist]
    let totalIPS: Int

nonisolated     enum CodingKeys: String, CodingKey {
        case totalBlocklists, currentBlocklist, blocklists
        case totalIPS = "totalIps"
    }
}

// MARK: - APIStatusResponse_ProcessBlocklistRefresh_Blocklist
nonisolated struct APIStatusResponse_ProcessBlocklistRefresh_Blocklist: Codable, Hashable, Sendable {
    let number: Int
    let name: String
    let steps: APIStatusResponse_ProcessBlocklistRefresh_Blocklist_Steps
}

// MARK: - APIStatusResponse_ProcessBlocklistRefresh_Blocklist_Steps
nonisolated struct APIStatusResponse_ProcessBlocklistRefresh_Blocklist_Steps: Codable, Hashable, Sendable {
    let fetch: APIStatusResponse_ProcessBlocklistFieldStatus
    let parse: APIStatusResponse_ProcessBlocklistFieldStatus
    let delete: APIStatusResponse_ProcessBlocklistFieldStatus
    let `import`: APIStatusResponse_ProcessBlocklistFieldStatus
}

