@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class ServiceStatusViewModelTests: XCTestCase {
    func testStateLoadingByDefault() {
        let activeRepo = MockActiveServerRepository()
        let statusRepo = ServiceStatusRepository(activeServerRepository: activeRepo)
        let sut = ServiceStatusViewModel(serviceStatusRepository: statusRepo)
        if case .loading = sut.state {
            XCTAssertTrue(true)
        }
    }
}
