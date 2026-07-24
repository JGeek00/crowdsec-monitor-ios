@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class RegExpsTests: XCTestCase {
    // MARK: - Domain regex

    func testDomainValid() {
        XCTAssertNotNil(try? RegExps.domain.wholeMatch(in: "example.com"))
        XCTAssertNotNil(try? RegExps.domain.wholeMatch(in: "sub.example.co.uk"))
        XCTAssertNotNil(try? RegExps.domain.wholeMatch(in: "my-domain.io"))
    }

    func testDomainInvalid() {
        XCTAssertNil(try? RegExps.domain.wholeMatch(in: "not_a_domain"))
        XCTAssertNil(try? RegExps.domain.wholeMatch(in: "-bad.com"))
        XCTAssertNil(try? RegExps.domain.wholeMatch(in: "a"))
        XCTAssertNil(try? RegExps.domain.wholeMatch(in: "a.b"))
    }

    // MARK: - URL regex

    func testUrlValid() {
        let predicate = NSPredicate(format: "SELF MATCHES %@", RegExps.url)
        XCTAssertTrue(predicate.evaluate(with: "http://example.com"))
        XCTAssertTrue(predicate.evaluate(with: "https://www.example.com/path?q=1"))
    }

    func testUrlInvalid() {
        let predicate = NSPredicate(format: "SELF MATCHES %@", RegExps.url)
        XCTAssertFalse(predicate.evaluate(with: "not a url"))
        XCTAssertFalse(predicate.evaluate(with: "ftp://x"))
    }
}
