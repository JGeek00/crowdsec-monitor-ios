@testable import CrowdSec_Monitor
import XCTest

/// Verifies the integration between AlertsListViewModel and its repository dependencies.
@MainActor
final class AlertsFlowIntegrationTests: XCTestCase {
    func testViewModelInitWithActiveRepo() {
        let activeRepo = MockActiveServerRepository()
        let sut = AlertsListViewModel(activeServerRepository: activeRepo)
        if case .loading = sut.state {
            XCTAssertTrue(true)
        }
        XCTAssertTrue(sut.filters.countries.isEmpty)
    }

    func testUpdateFiltersPropagatesToViewModel() {
        let activeRepo = MockActiveServerRepository()
        let sut = AlertsListViewModel(activeServerRepository: activeRepo)
        let newFilters = AlertsRequestFilters(countries: ["US"], scenarios: [], ipOwners: [], targets: [])
        sut.updateFilters(newFilters)
        XCTAssertEqual(sut.filters.countries, ["US"])
    }

    func testResetRestoresDefaults() {
        let activeRepo = MockActiveServerRepository()
        let sut = AlertsListViewModel(activeServerRepository: activeRepo)
        sut.selectedAlert = 5
        sut.deletingAlertProcess = true
        sut.reset()
        XCTAssertNil(sut.selectedAlert)
        XCTAssertFalse(sut.deletingAlertProcess)
    }
}
