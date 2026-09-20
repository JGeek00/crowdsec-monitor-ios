@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class OpenURLTests: XCTestCase {
    func testOpenURLInvalidReturnsEarly() {
        // Invalid URL — should print and return without crashing
        openURL("") // No crash = pass
    }

    func testOpenURLValidDoesNotCrash() {
        // A valid URL — should not crash even on simulator where canOpenURL may be false
        openURL("https://example.com")
    }
}
