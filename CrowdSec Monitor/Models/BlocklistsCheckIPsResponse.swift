import Foundation

// MARK: - BlocklistsCheckIPsResponse
struct BlocklistsCheckIPsResponse: Codable, Hashable, Sendable {
    let results: [BlocklistsCheckIPsResponse_Result]
}

// MARK: - BlocklistsCheckIPsResponse_Result
struct BlocklistsCheckIPsResponse_Result: Codable, Hashable, Sendable {
    let ip: String
    let blocklists: [String]
}
