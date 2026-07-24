@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class BlocklistDetailsViewModelTests: XCTestCase {
    func testStateLoadingByDefault() {
        let activeRepo = MockActiveServerRepository()
        let statusRepo = ServiceStatusRepository(activeServerRepository: activeRepo)
        let sut = BlocklistDetailsViewModel(
            blocklistId: "test-id",
            activeServerRepository: activeRepo,
            serviceStatusRepository: statusRepo
        )
        if case .loading = sut.status {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected loading state")
        }
    }

    func testBlocklistId() {
        let activeRepo = MockActiveServerRepository()
        let statusRepo = ServiceStatusRepository(activeServerRepository: activeRepo)
        let sut = BlocklistDetailsViewModel(
            blocklistId: "bl-42",
            activeServerRepository: activeRepo,
            serviceStatusRepository: statusRepo
        )
        XCTAssertEqual(sut.blocklistId, "bl-42")
    }
}
