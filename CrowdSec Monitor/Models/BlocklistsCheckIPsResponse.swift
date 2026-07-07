import Foundation

// MARK: - BlocklistsCheckIPsResponse
nonisolated struct BlocklistsCheckIPsResponse: Codable, Hashable, Sendable {
    let results: [BlocklistsCheckIPsResponse_Result]
}

// MARK: - BlocklistsCheckIPsResponse_Result
nonisolated struct BlocklistsCheckIPsResponse_Result: Codable, Hashable, Sendable {
    let ip: String
    let blocklists: [String]
}
