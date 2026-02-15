import Foundation

extension Date {
    /// Formats the date as yyyy-MM-dd string
    func toYYYYMMDD() -> String {
        return DateFormatter.yyyyMMdd.string(from: self)
    }
}
