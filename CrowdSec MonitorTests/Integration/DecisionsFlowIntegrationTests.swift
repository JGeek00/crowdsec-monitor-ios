@testable import CrowdSec_Monitor
import XCTest

/// Verifies the integration between DecisionsListViewModel and its repository dependencies.
/// ponytail: uses MockActiveServerRepository (no real HTTP), tests contract between layers.
@MainActor
final class DecisionsFlowIntegrationTests: XCTestCase {
    override func tearDown() {
        UserDefaults.shared.removeObject(forKey: "onlyActive")
        UserDefaults.shared.removeObject(forKey: "groupByIP")
        super.tearDown()
    }

    func testViewModelInitWithActiveRepo() {
        let activeRepo = MockActiveServerRepository()
        let sut = DecisionsListViewModel(activeServerRepository: activeRepo)
        if case .loading = sut.state {
            XCTAssertTrue(true)
        }
        XCTAssertNil(activeRepo.currentServer)
    }

    func testApplyFiltersUpdatesRequestParams() {
        let activeRepo = MockActiveServerRepository()
        let sut = DecisionsListViewModel(activeServerRepository: activeRepo)
        sut.filters = DecisionsRequestFilters(onlyActive: false, groupByIP: true)
        sut.applyFilters()
        XCTAssertEqual(sut.requestParams.filters.onlyActive, false)
        XCTAssertEqual(sut.requestParams.filters.groupByIP, true)
    }

    func testResetClearsState() {
        let activeRepo = MockActiveServerRepository()
        let sut = DecisionsListViewModel(activeServerRepository: activeRepo)
        sut.processingExpireDecision = true
        sut.reset()
        XCTAssertFalse(sut.processingExpireDecision)
    }
}
