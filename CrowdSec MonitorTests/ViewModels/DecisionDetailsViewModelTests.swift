@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class DecisionDetailsViewModelTests: XCTestCase {
    func testStateLoadingByDefault() {
        let sut = DecisionDetailsViewModel(decisionId: 1, activeServerRepository: MockActiveServerRepository())
        if case .loading = sut.state {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected loading state")
        }
    }

    func testDecisionId() {
        let sut = DecisionDetailsViewModel(decisionId: 99, activeServerRepository: MockActiveServerRepository())
        XCTAssertEqual(sut.decisionId, 99)
    }
}
