import Foundation

extension String {
    /// Converts a string in "yyyy-MM-dd" format to a Date object
    /// - Returns: Date object if the string can be parsed, nil otherwise
    func toDateFromYYYYMMDD() -> Date? {
        return DateFormatter.yyyyMMdd.date(from: self)
    }
    
    /// Converts an ISO 8601 formatted string to a Date object
    /// - Returns: Date object if the string can be parsed, nil otherwise
    func toDateFromISO8601() -> Date? {
        // Try with fractional seconds first
        if let date = DateFormatter.iso8601WithFractionalSeconds.date(from: self) {
            return date
        }
        
        // Fallback to standard ISO8601DateFormatter
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: self)
    }
}
