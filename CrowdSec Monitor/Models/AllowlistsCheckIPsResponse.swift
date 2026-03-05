import Foundation

// MARK: - AllowlistsCheckIPSResponse
struct AllowlistsCheckIPSResponse: Codable, Hashable {
    let results: [AllowlistsCheckIPSResponse_Result]
}

// MARK: - AllowlistsCheckIPSResponse_Result
struct AllowlistsCheckIPSResponse_Result: Codable, Hashable {
    let ip: String
    let allowlist: String?
}
