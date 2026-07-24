@testable import CrowdSec_Monitor
import CoreData
import XCTest

@MainActor
final class DashboardViewModelTests: XCTestCase {
    func testStateLoadingByDefault() {
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
        } else {
            XCTFail("Expected loading state")
        }
    }

    func testCurrentServerNilByDefault() {
        let activeRepo = MockActiveServerRepository()
        let serversRepo = ServersManagerRepository(activeServerRepository: activeRepo)
        let statusRepo = ServiceStatusRepository(activeServerRepository: activeRepo)
        let sut = DashboardViewModel(
            activeServerRepository: activeRepo,
            serversManagerRepository: serversRepo,
            serviceStatusRepository: statusRepo
        )
        XCTAssertNil(sut.currentServer)
    }
}
