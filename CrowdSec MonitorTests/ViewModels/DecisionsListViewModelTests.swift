@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class DecisionsListViewModelTests: XCTestCase {
    override func tearDown() {
        UserDefaults.shared.removeObject(forKey: "onlyActive")
        UserDefaults.shared.removeObject(forKey: "groupByIP")
        super.tearDown()
    }

    func testStateLoadingByDefault() {
        let sut = DecisionsListViewModel(activeServerRepository: MockActiveServerRepository())
        if case .loading = sut.state {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected loading state")
        }
    }

    func testDefaultFiltersFromConfig() {
        let sut = DecisionsListViewModel(activeServerRepository: MockActiveServerRepository())
        XCTAssertEqual(sut.filters.onlyActive, Defaults.showDefaultActiveDecisions)
        XCTAssertEqual(sut.filters.groupByIP, Defaults.showDefaultDecisionsGroupedByIP)
    }

    func testReset() {
        let sut = DecisionsListViewModel(activeServerRepository: MockActiveServerRepository())
        sut.processingExpireDecision = true
        sut.reset()
        XCTAssertFalse(sut.processingExpireDecision)
        if case .loading = sut.state {
            XCTAssertTrue(true)
        }
    }

    func testApplyFilters() {
        let sut = DecisionsListViewModel(activeServerRepository: MockActiveServerRepository())
        sut.filters = DecisionsRequestFilters(onlyActive: false, groupByIP: true)
        sut.applyFilters()
        XCTAssertEqual(sut.requestParams.filters.onlyActive, false)
        XCTAssertEqual(sut.requestParams.filters.groupByIP, true)
    }

    func testResetFilters() {
        let sut = DecisionsListViewModel(activeServerRepository: MockActiveServerRepository())
        sut.filters = DecisionsRequestFilters(onlyActive: false, groupByIP: true)
        sut.applyFilters()
        sut.resetFilters()
        XCTAssertEqual(sut.filters.onlyActive, Defaults.showDefaultActiveDecisions)
        XCTAssertEqual(sut.filters.groupByIP, Defaults.showDefaultDecisionsGroupedByIP)
    }
}
