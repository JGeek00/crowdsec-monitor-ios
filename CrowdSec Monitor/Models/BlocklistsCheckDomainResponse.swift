import Foundation

// MARK: - BlocklistsCheckDomainResponse
 struct BlocklistsCheckDomainResponse: Codable, Hashable, Sendable {
    let domain: String
    let ips: [BlocklistsCheckDomainResponse_IP]
}

// MARK: - BlocklistsCheckDomainResponse_IP
 struct BlocklistsCheckDomainResponse_IP: Codable, Hashable, Sendable {
    let ip: String
    let blocklists: [String]
}
