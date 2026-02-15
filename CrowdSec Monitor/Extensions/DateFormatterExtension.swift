import Foundation

extension DateFormatter {
    /// Returns a DateFormatter configured for yyyy-MM-dd format
    static var yyyyMMdd: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }
}
