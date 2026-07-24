@testable import CrowdSec_Monitor
import XCTest

final class DateFormatterExtensionTests: XCTestCase {
    func testYYYYMMddFormatter() {
        let formatter = DateFormatter.yyyyMMdd
        let date = makeDate(year: 2026, month: 2, day: 14)
        XCTAssertEqual(formatter.string(from: date), "2026-02-14")
        // round-trip
        let string = "2026-12-25"
        let parsed = formatter.date(from: string)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(formatter.string(from: parsed!), string)
    }

    func testDdMMMyyyyHHmmssFormatter() {
        let formatter = DateFormatter.ddMMMyyyyHHmmss
        let date = makeDate(year: 2026, month: 2, day: 14, hour: 9, minute: 5, second: 30)
        // "14 Feb. 2026 09:05:30"
        let result = formatter.string(from: date)
        XCTAssertTrue(result.contains("Feb"))
        XCTAssertTrue(result.contains("2026"))
    }

    func testIso8601WithFractionalSecondsFormatter() {
        let formatter = DateFormatter.iso8601WithFractionalSeconds
        let date = makeDate(year: 2026, month: 2, day: 14, hour: 20, minute: 29, second: 54)
        let result = formatter.string(from: date)
        // Should contain the date
        XCTAssertTrue(result.hasPrefix("2026-02-14T20:29:54"))
        // Round-trip
        let parsed = formatter.date(from: result)
        XCTAssertNotNil(parsed)
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
