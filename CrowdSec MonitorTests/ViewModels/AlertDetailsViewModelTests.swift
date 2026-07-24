@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class AlertDetailsViewModelTests: XCTestCase {
    func testStateLoadingByDefault() {
        let sut = AlertDetailsViewModel(alertId: 1, activeServerRepository: MockActiveServerRepository())
        if case .loading = sut.state {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected loading state")
        }
    }

    func testAlertId() {
        let sut = AlertDetailsViewModel(alertId: 42, activeServerRepository: MockActiveServerRepository())
        XCTAssertEqual(sut.alertId, 42)
    }
}
