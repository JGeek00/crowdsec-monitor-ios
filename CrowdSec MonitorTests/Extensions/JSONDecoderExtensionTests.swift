@testable import CrowdSec_Monitor
import XCTest

final class JSONDecoderExtensionTests: XCTestCase {
    private struct TestDateContainer: Decodable {
        let date: Date
    }

    func testDecodesISO8601WithFractionalSeconds() throws {
        let json = #"{"date": "2026-02-14T20:29:54.000Z"}"#.data(using: .utf8)!
        let decoded = try JSONDecoder.api.decode(TestDateContainer.self, from: json)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let expected = try XCTUnwrap(formatter.date(from: "2026-02-14T20:29:54.000Z"))
        XCTAssertEqual(decoded.date.timeIntervalSinceReferenceDate,
                       expected.timeIntervalSinceReferenceDate,
                       accuracy: 0.001)
    }

    func testDecodesCustomTimestamp() throws {
        let json = #"{"date": "2026-02-14 21:29:50 +0100 +0100"}"#.data(using: .utf8)!
        let decoded = try JSONDecoder.api.decode(TestDateContainer.self, from: json)
        // Custom format: "2026-02-14 21:29:50 +0100 +0100" = Feb 14, 2026 20:29:50 UTC
        let customFormatter = DateFormatter()
        customFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z Z"
        customFormatter.locale = Locale(identifier: "en_US_POSIX")
        let expected = try XCTUnwrap(customFormatter.date(from: "2026-02-14 21:29:50 +0100 +0100"))
        XCTAssertEqual(decoded.date.timeIntervalSinceReferenceDate,
                       expected.timeIntervalSinceReferenceDate,
                       accuracy: 0.001)
    }

    func testInvalidDateStringThrows() {
        let json = #"{"date": "not-a-date"}"#.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder.api.decode(TestDateContainer.self, from: json)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }
}
