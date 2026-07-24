@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class SharedAppStorageTests: XCTestCase {
    override func tearDown() {
        UserDefaults.shared.removeObject(forKey: "TEST_string")
        UserDefaults.shared.removeObject(forKey: "TEST_int")
        UserDefaults.shared.removeObject(forKey: "TEST_bool")
        super.tearDown()
    }

    func testStringRoundTrip() {
        @SharedAppStorage("TEST_string") var value: String = "default"
        XCTAssertEqual(value, "default")
        value = "updated"
        XCTAssertEqual(value, "updated")
        // Verify it persisted to UserDefaults.shared
        XCTAssertEqual(UserDefaults.shared.string(forKey: "TEST_string"), "updated")
    }

    func testIntRoundTrip() {
        @SharedAppStorage("TEST_int") var value: Int = 0
        XCTAssertEqual(value, 0)
        value = 42
        XCTAssertEqual(value, 42)
        XCTAssertEqual(UserDefaults.shared.integer(forKey: "TEST_int"), 42)
    }

    func testBoolRoundTrip() {
        @SharedAppStorage("TEST_bool") var value: Bool = false
        XCTAssertEqual(value, false)
        value = true
        XCTAssertEqual(value, true)
        XCTAssertEqual(UserDefaults.shared.bool(forKey: "TEST_bool"), true)
    }
}
