import Foundation

// MARK: - Shared JSON Decoder

extension JSONDecoder {
    /// A decoder configured with the date‑decoding strategy used by both
    /// HTTP and WebSocket responses from the CrowdSec API.
    nonisolated static var api: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Try ISO8601 with milliseconds format: "2026-02-14T20:29:54.000Z"
            let iso8601Formatter = ISO8601DateFormatter()
            iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = iso8601Formatter.date(from: dateString) {
                return date
            }

            // Try RFC 3339 UTC without fractional seconds: "2026-09-27T10:40:36Z" (current API format)
            let rfc3339Formatter = ISO8601DateFormatter()
            rfc3339Formatter.formatOptions = [.withInternetDateTime]
            if let date = rfc3339Formatter.date(from: dateString) {
                return date
            }

            // Try custom timestamp format: "2026-02-14 21:29:50 +0100 +0100"
            let customFormatter = DateFormatter()
            customFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z Z"
            customFormatter.locale = Locale(identifier: "en_US_POSIX")
            if let date = customFormatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date string: \(dateString)"
            )
        }
        return decoder
    }
}
