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
    
    /// Returns "hoy" if today, "ayer" if yesterday, or "dd-MM-yyyy" format for other dates
    /// - Returns: Formatted date string based on relative day
    func toRelativeDayString() -> String {
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
    func toTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: self)
    }
}

