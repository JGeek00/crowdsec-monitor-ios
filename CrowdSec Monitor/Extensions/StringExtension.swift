import Foundation

extension String {
    /// Converts a string in "yyyy-MM-dd" format to a Date object
    /// - Returns: Date object if the string can be parsed, nil otherwise
    func toDateFromYYYYMMDD() -> Date? {
        return DateFormatter.yyyyMMdd.date(from: self)
    }
}
