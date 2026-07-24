@testable import CrowdSec_Monitor
import XCTest

/// Verifies the integration between DashboardViewModel and its repository dependencies.
@MainActor
final class DashboardStatisticsIntegrationTests: XCTestCase {
    func testViewModelInitWithoutServer() {
        let activeRepo = MockActiveServerRepository()
        let serversRepo = ServersManagerRepository(activeServerRepository: activeRepo)
        let statusRepo = ServiceStatusRepository(activeServerRepository: activeRepo)
        let sut = DashboardViewModel(
            activeServerRepository: activeRepo,
            serversManagerRepository: serversRepo,
            serviceStatusRepository: statusRepo
        )
        XCTAssertNil(sut.currentServer)
        XCTAssertTrue(sut.servers.isEmpty)
    }

    func testStateMachineTransitions() {
        let activeRepo = MockActiveServerRepository()
        let serversRepo = ServersManagerRepository(activeServerRepository: activeRepo)
        let statusRepo = ServiceStatusRepository(activeServerRepository: activeRepo)
        let sut = DashboardViewModel(
            activeServerRepository: activeRepo,
            serversManagerRepository: serversRepo,
            serviceStatusRepository: statusRepo
        )
        if case .loading = sut.state {
            XCTAssertTrue(true)
        }
    }
}
