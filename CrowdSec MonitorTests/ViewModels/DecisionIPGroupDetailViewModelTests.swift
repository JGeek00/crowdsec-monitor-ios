@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class DecisionIPGroupDetailViewModelTests: XCTestCase {
    func testStateLoadingByDefault() {
        let sut = DecisionIPGroupDetailViewModel(
            ip: "10.0.0.1",
            onlyActive: true,
            activeServerRepository: MockActiveServerRepository()
        )
        if case .loading = sut.state {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected loading state")
        }
    }

    func testIP() {
        let sut = DecisionIPGroupDetailViewModel(
            ip: "192.168.1.1",
            onlyActive: true,
            activeServerRepository: MockActiveServerRepository()
        )
        XCTAssertEqual(sut.ip, "192.168.1.1")
    }
}
