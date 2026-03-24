import Foundation

// MARK: - Generic API Error Response (e.g. 422 { "error": "..." } or { "message": "..." })

struct ApiErrorResponse: Decodable {
    let error: String?
    let message: String?
    
    var resolvedMessage: String? { error ?? message }
}
