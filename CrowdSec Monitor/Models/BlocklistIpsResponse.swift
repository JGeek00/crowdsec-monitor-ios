import Foundation

// MARK: - BlocklistIpsResponse
struct BlocklistIpsResponse: Codable {
    let data: [String]
    let total, limit, offset: Int
}
