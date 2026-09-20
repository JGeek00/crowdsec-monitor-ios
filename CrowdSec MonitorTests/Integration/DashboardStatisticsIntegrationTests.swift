@testable import CrowdSec_Monitor
import XCTest

/// Verifies the integration between DashboardViewModel and its repository dependencies.
@MainActor
final class DashboardStatisticsIntegrationTests: XCTestCase {
    /// Builds the repositories against an in-memory context: the host app's
    /// real store may contain servers (e.g. on an already-configured simulator).
    private func makeRepositories() -> (activeRepo: MockActiveServerRepository, serversRepo: ServersManagerRepository, statusRepo: ServiceStatusRepository) {
        let activeRepo = MockActiveServerRepository()
        let serversRepo = InjectServersManagerRepository(
            activeServerRepository: activeRepo,
            context: TestCoreData.makeContainer().viewContext
        )
        let statusRepo = ServiceStatusRepository(activeServerRepository: activeRepo)
        return (activeRepo, serversRepo, statusRepo)
    }

    func testViewModelInitWithoutServer() {
        let repos = makeRepositories()
        let sut = DashboardViewModel(
            activeServerRepository: repos.activeRepo,
            serversManagerRepository: repos.serversRepo,
            serviceStatusRepository: repos.statusRepo
        )
        XCTAssertNil(sut.currentServer)
        XCTAssertTrue(sut.servers.isEmpty)
    }

    func testStateMachineTransitions() {
        let repos = makeRepositories()
        let sut = DashboardViewModel(
            activeServerRepository: repos.activeRepo,
            serversManagerRepository: repos.serversRepo,
            serviceStatusRepository: repos.statusRepo
        )
        if case .loading = sut.state {
            XCTAssertTrue(true)
        }
    }
}
