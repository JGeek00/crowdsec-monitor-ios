import Foundation

// MARK: - CheckIPsResponse
struct CheckIPsResponse: Codable, Hashable {
    let results: [CheckIPsResponse_Result]
}

// MARK: - CheckIPsResponse_Result
struct CheckIPsResponse_Result: Codable, Hashable {
    let ip: String
    let allowlist: String?
    let blocklist: String?
}
