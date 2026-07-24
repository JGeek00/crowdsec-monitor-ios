@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class FullListDashboardItemViewModelTests: XCTestCase {
    func testStateLoadingByDefault() {
        let sut = FullListDashboardItemViewModel(
            dashboardItem: .country,
            activeServerRepository: MockActiveServerRepository()
        )
        if case .loading = sut.state {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected loading state")
        }
    }

    func testDashboardItemType() {
        let sut = FullListDashboardItemViewModel(
            dashboardItem: .scenary,
            activeServerRepository: MockActiveServerRepository()
        )
        XCTAssertEqual(sut.dashboardItem, .scenary)
    }
}
