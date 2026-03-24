import Foundation

// MARK: - AllowlistsCheckIPsResponse
struct AllowlistsCheckIPsResponse: Codable, Hashable {
    let results: [AllowlistsCheckIPsResponse_Result]
}

// MARK: - AllowlistsCheckIPsResponse_Result
struct AllowlistsCheckIPsResponse_Result: Codable, Hashable {
    let ip: String
    let allowlist: String?
}
