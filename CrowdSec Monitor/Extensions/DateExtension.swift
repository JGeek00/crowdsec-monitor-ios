import Foundation

extension Date {
    /// Converts the date to "yyyy-MM-dd" format string
    /// - Returns: Formatted date string in yyyy-MM-dd format
    nonisolated func toYYYYMMDD() -> String {
        return DateFormatter.yyyyMMdd.string(from: self)
    }
    
    /// Returns "hoy" if today, "ayer" if yesterday, or "dd-MM-yyyy" format for other dates
    /// - Returns: Formatted date string based on relative day
    nonisolated func toRelativeDayString() -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(self) {
            return String(localized: "today")
        } else if calendar.isDateInYesterday(self) {
            return String(localized: "yesterday")
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            return formatter.string(from: self)
        }
    }
    
    /// Returns time in "HH:mm:ss" format
    /// - Returns: Formatted time string
    nonisolated func toTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: self)
    }

    /// Returns the creation moment for display: "hoy, 14:32:17" when the date is today,
    /// "ayer, 14:32:17" when it was yesterday, and "14 febrero 2026 14:32:17"
    /// (localized month name and relative day) otherwise.
    /// - Parameter locale: Locale used for the localized words and month names.
    /// - Returns: Formatted string based on the relative day.
    nonisolated func toRelativeDateTimeString(locale: Locale = .current) -> String {
        let calendar = Calendar.current
        let time = toTimeString()
        if calendar.isDateInToday(self) {
            return "\(String(localized: "today")), \(time)"
        }
        if calendar.isDateInYesterday(self) {
            return "\(String(localized: "yesterday")), \(time)"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy HH:mm:ss"
        formatter.locale = locale
        return formatter.string(from: self)
    }
}

