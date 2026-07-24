@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class BlocklistsListViewModelTests: XCTestCase {
    func testStateLoadingByDefault() {
        let activeRepo = MockActiveServerRepository()
        let statusRepo = ServiceStatusRepository(activeServerRepository: activeRepo)
        let sut = BlocklistsListViewModel(
            activeServerRepository: activeRepo,
            serviceStatusRepository: statusRepo
        )
        if case .loading = sut.state {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected loading state")
        }
    }

    func testDefaultValues() {
        let activeRepo = MockActiveServerRepository()
        let statusRepo = ServiceStatusRepository(activeServerRepository: activeRepo)
        let sut = BlocklistsListViewModel(
            activeServerRepository: activeRepo,
            serviceStatusRepository: statusRepo
        )
        XCTAssertEqual(sut.requestParams.offset, 0)
        XCTAssertEqual(sut.requestParams.limit, Config.blocklistsAmountBatch)
    }
}
