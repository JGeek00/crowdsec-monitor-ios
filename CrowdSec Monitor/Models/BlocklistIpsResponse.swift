import Foundation

// MARK: - BlocklistIpsResponse
nonisolated struct BlocklistIpsResponse: Codable {
    let data: [String]
    let total, limit, offset: Int
}
