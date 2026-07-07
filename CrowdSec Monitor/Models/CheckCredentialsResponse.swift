import Foundation

nonisolated struct CheckCredentialsResponse: Codable, Sendable {
    let message: String
    let timestamp: String
}
