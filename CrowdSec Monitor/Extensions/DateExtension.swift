import Foundation

extension Date {
    /// Converts the date to "yyyy-MM-dd" format string
    /// - Returns: Formatted date string in yyyy-MM-dd format
    func toYYYYMMDD() -> String {
        return DateFormatter.yyyyMMdd.string(from: self)
    }
    
    /// Formats the date as "MMM dd" (e.g., "Feb 09")
    /// - Returns: Formatted date string
    func toShortDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter.string(from: self)
    }
}
