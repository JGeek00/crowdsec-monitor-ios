import Foundation

// MARK: - AllowlistsCheckIPsResponse
struct AllowlistsCheckIPsResponse: Codable, Hashable, Sendable {
    let results: [AllowlistsCheckIPsResponse_Result]
}

// MARK: - AllowlistsCheckIPsResponse_Result
struct AllowlistsCheckIPsResponse_Result: Codable, Hashable, Sendable {
    let ip: String
    let allowlist: String?
}
