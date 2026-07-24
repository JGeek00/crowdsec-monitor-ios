@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class UserDefaultsExtensionTests: XCTestCase {
    override func tearDown() {
        UserDefaults.shared.removeObject(forKey: "TEST_string")
        UserDefaults.shared.removeObject(forKey: "TEST_int")
        super.tearDown()
    }

    func testSharedIsNonNil() {
        XCTAssertNotNil(UserDefaults.shared)
    }

    func testSharedRoundTripsString() {
        UserDefaults.shared.set("hello", forKey: "TEST_string")
        XCTAssertEqual(UserDefaults.shared.string(forKey: "TEST_string"), "hello")
    }

    func testSharedRoundTripsInt() {
        UserDefaults.shared.set(42, forKey: "TEST_int")
        XCTAssertEqual(UserDefaults.shared.integer(forKey: "TEST_int"), 42)
    }
}
