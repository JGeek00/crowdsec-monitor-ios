@testable import CrowdSec_Monitor
import XCTest

final class DateExtensionTests: XCTestCase {
    func testToYYYYMMDD() {
        let date = makeDate(year: 2026, month: 2, day: 14)
        XCTAssertEqual(date.toYYYYMMDD(), "2026-02-14")
    }

    func testToRelativeDayStringToday() {
        let today = Date()
        let result = today.toRelativeDayString()
        // Should be "today" (localized)
        XCTAssertFalse(result.isEmpty)
    }

    func testToRelativeDayStringYesterday() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let result = yesterday.toRelativeDayString()
        XCTAssertFalse(result.isEmpty)
    }

    func testToRelativeDayStringOther() {
        let farPast = makeDate(year: 2020, month: 1, day: 1)
        XCTAssertEqual(farPast.toRelativeDayString(), "01-01-2020")
    }

    func testToTimeString() {
        let fixed = makeDate(year: 2026, month: 2, day: 14, hour: 9, minute: 5, second: 30)
        XCTAssertEqual(fixed.toTimeString(), "09:05:30")
    }

    // MARK: - Helpers

    private func makeDate(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        return Calendar.current.date(from: components)!
    }
}
