import Foundation

// MARK: - BlocklistsCheckIPsResponse
struct BlocklistsCheckIPsResponse: Codable, Hashable {
    let results: [BlocklistsCheckIPsResponse_Result]
}

// MARK: - BlocklistsCheckIPsResponse_Result
struct BlocklistsCheckIPsResponse_Result: Codable, Hashable {
    let ip: String
    let blocklists: [String]
}
