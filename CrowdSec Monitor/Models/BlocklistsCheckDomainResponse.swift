import Foundation

// MARK: - BlocklistDataResponse
struct BlocklistsCheckDomainResponse: Codable, Hashable {
    let domain: String
    let reachable: Bool
    let hops: [BlocklistsCheckDomainResponse_Hop]
}

// MARK: - BlocklistsCheckDomainResponse_Hop
struct BlocklistsCheckDomainResponse_Hop: Codable, Hashable {
    let hop: Int
    let ip: String?
    let timedOut: Bool
    let blocklist: String?

    enum CodingKeys: String, CodingKey {
        case hop, ip
        case timedOut = "timed_out"
        case blocklist
    }
}
