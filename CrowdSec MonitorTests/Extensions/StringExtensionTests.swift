@testable import CrowdSec_Monitor
import XCTest

final class StringExtensionTests: XCTestCase {
    func testToDateFromYYYYMMDDValid() {
        let result = "2026-02-14".toDateFromYYYYMMDD()
        XCTAssertNotNil(result)
        let formatter = DateFormatter.yyyyMMdd
        XCTAssertEqual(formatter.string(from: result!), "2026-02-14")
    }

    func testToDateFromYYYYMMDDInvalid() {
        XCTAssertNil("not-a-date".toDateFromYYYYMMDD())
        XCTAssertNil("2026-13-01".toDateFromYYYYMMDD())
        XCTAssertNil("".toDateFromYYYYMMDD())
    }

    func testToDateFromISO8601WithFractionalSeconds() {
        let result = "2026-02-14T20:29:54.000Z".toDateFromISO8601()
        XCTAssertNotNil(result)
    }

    func testToDateFromISO8601Invalid() {
        XCTAssertNil("".toDateFromISO8601())
        XCTAssertNil("not-a-date".toDateFromISO8601())
    }
}
