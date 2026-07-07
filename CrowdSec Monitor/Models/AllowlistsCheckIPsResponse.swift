import Foundation

// MARK: - AllowlistsCheckIPsResponse
nonisolated struct AllowlistsCheckIPsResponse: Codable, Hashable, Sendable {
    let results: [AllowlistsCheckIPsResponse_Result]
}

// MARK: - AllowlistsCheckIPsResponse_Result
nonisolated struct AllowlistsCheckIPsResponse_Result: Codable, Hashable, Sendable {
    let ip: String
    let allowlist: String?
}
