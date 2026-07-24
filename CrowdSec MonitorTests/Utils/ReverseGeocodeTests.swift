@testable import CrowdSec_Monitor
import XCTest

final class ReverseGeocodeTests: XCTestCase {
    func testReverseGeocode() async {
        // Just verify the function signature compiles and runs.
        // Meaningful geocoding assertions require mocking CLGeocoder.
        _ = await reverseGeocode(lat: 0, lon: 0)
    }
}
