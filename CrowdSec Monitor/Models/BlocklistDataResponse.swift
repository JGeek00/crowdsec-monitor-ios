import Foundation

// MARK: - BlocklistDataResponse
struct BlocklistDataResponse: Codable {
    let data: BlocklistDataResponse_Data
}

// MARK: - BlocklistDataResponse_Data
struct BlocklistDataResponse_Data: Codable {
    let id: Int
    let name: String
    let countIPS: Int
    let blocklistIPS: [String]

    enum CodingKeys: String, CodingKey {
        case id, name
        case countIPS = "count_ips"
        case blocklistIPS = "blocklistIps"
    }
}
