import Foundation

// MARK: - ApiStatusResponse
struct ApiStatusResponse: Codable {
    let csLapi: ApiStatusResponse_CSLapi
    let csMonitorAPI: ApiStatusResponse_CSMonitorAPI

    enum CodingKeys: String, CodingKey {
        case csLapi
        case csMonitorAPI = "csMonitorApi"
    }
}

// MARK: - ApiStatusResponse_CSLapi
struct ApiStatusResponse_CSLapi: Codable {
    let lapiConnected: Bool
    let lastSuccessfulSync, timestamp: String
}

// MARK: - ApiStatusResponse_CSMonitorAPI
struct ApiStatusResponse_CSMonitorAPI: Codable {
    let version: String
    let newVersionAvailable: String?
}
