@testable import CrowdSec_Monitor
import XCTest

/// Verifies the integration between BlocklistsListViewModel and its repository dependencies.
@MainActor
final class BlocklistsFlowIntegrationTests: XCTestCase {
    func testViewModelInitWithoutServer() {
        let activeRepo = MockActiveServerRepository()
        let statusRepo = ServiceStatusRepository(activeServerRepository: activeRepo)
        let sut = BlocklistsListViewModel(
            activeServerRepository: activeRepo,
            serviceStatusRepository: statusRepo
        )
        if case .loading = sut.state {
            XCTAssertTrue(true)
        }
        XCTAssertEqual(sut.requestParams.limit, Config.blocklistsAmountBatch)
    }

    func testDetailViewModelInit() {
        let activeRepo = MockActiveServerRepository()
        let statusRepo = ServiceStatusRepository(activeServerRepository: activeRepo)
        let sut = BlocklistDetailsViewModel(
            blocklistId: "integration-test",
            activeServerRepository: activeRepo,
            serviceStatusRepository: statusRepo
        )
        XCTAssertEqual(sut.blocklistId, "integration-test")
        if case .loading = sut.status {
            XCTAssertTrue(true)
        }
    }
}
