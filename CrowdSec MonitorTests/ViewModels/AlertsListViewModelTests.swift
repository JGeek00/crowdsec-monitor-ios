@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class AlertsListViewModelTests: XCTestCase {
    func testStateLoadingByDefault() {
        let sut = AlertsListViewModel(activeServerRepository: MockActiveServerRepository())
        if case .loading = sut.state {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected loading state")
        }
    }

    func testDefaultFiltersEmpty() {
        let sut = AlertsListViewModel(activeServerRepository: MockActiveServerRepository())
        XCTAssertTrue(sut.filters.countries.isEmpty)
        XCTAssertTrue(sut.filters.scenarios.isEmpty)
    }

    func testReset() {
        let sut = AlertsListViewModel(activeServerRepository: MockActiveServerRepository())
        sut.selectedAlert = 5
        sut.deletingAlertProcess = true
        sut.reset()
        XCTAssertNil(sut.selectedAlert)
        XCTAssertFalse(sut.deletingAlertProcess)
        if case .loading = sut.state {
            XCTAssertTrue(true)
        }
    }

    func testUpdateFilters() {
        let sut = AlertsListViewModel(activeServerRepository: MockActiveServerRepository())
        let newFilters = AlertsRequestFilters(countries: ["US"], scenarios: [], ipOwners: [], targets: [])
        sut.updateFilters(newFilters)
        XCTAssertEqual(sut.filters.countries, ["US"])
    }

    func testResetFilters() {
        let sut = AlertsListViewModel(activeServerRepository: MockActiveServerRepository())
        sut.updateFilters(AlertsRequestFilters(countries: ["US"], scenarios: [], ipOwners: [], targets: []))
        sut.resetFilters()
        XCTAssertTrue(sut.filters.countries.isEmpty)
    }
}
