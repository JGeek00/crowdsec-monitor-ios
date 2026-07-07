import Foundation

// MARK: - BlocklistsCheckDomainResponse
nonisolated struct BlocklistsCheckDomainResponse: Codable, Hashable, Sendable {
    let domain: String
    let ips: [BlocklistsCheckDomainResponse_IP]
}

// MARK: - BlocklistsCheckDomainResponse_IP
nonisolated struct BlocklistsCheckDomainResponse_IP: Codable, Hashable, Sendable {
    let ip: String
    let blocklists: [String]
}
