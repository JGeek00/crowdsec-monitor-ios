import Foundation

extension String {
    /// Converts a string in "yyyy-MM-dd" format to a Date object
    /// - Returns: Date object if the string can be parsed, nil otherwise
    nonisolated func toDateFromYYYYMMDD() -> Date? {
        return DateFormatter.yyyyMMdd.date(from: self)
    }
    
    /// Converts an ISO 8601 formatted string to a Date object
    /// - Returns: Date object if the string can be parsed, nil otherwise
    nonisolated func toDateFromISO8601() -> Date? {
        // RFC 3339 UTC without fractional seconds: "2026-09-27T10:40:36Z" (current API format)
        if let date = DateFormatter.iso8601.date(from: self) {
            return date
        }

        // ISO 8601 with fractional seconds: "2026-02-14T20:29:54.000Z"
        if let date = DateFormatter.iso8601WithFractionalSeconds.date(from: self) {
            return date
        }
        
        // Fallback to standard ISO8601DateFormatter
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: self)
    }
}
