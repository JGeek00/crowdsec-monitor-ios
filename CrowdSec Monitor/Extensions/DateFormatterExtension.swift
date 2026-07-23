import Foundation

extension DateFormatter {
    /// Returns a DateFormatter configured for yyyy-MM-dd format
    nonisolated static var yyyyMMdd: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    /// Returns a DateFormatter configured for "dd MMM. yyyy HH:mm:ss" format
    nonisolated static var ddMMMyyyyHHmmss: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM. yyyy HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }

    /// Returns a DateFormatter configured for ISO 8601 format with fractional seconds
    nonisolated static var iso8601WithFractionalSeconds: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }
}
