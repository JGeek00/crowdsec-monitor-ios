@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class InformationSectionViewModelTests: XCTestCase {
    func testHasServerConfiguredFalseByDefault() {
        let activeRepo = MockActiveServerRepository()
        let statusRepo = ServiceStatusRepository(activeServerRepository: activeRepo)
        let sut = InformationSectionViewModel(
            serviceStatusRepository: statusRepo,
            activeServerRepository: activeRepo
        )
        XCTAssertFalse(sut.hasServerConfigured)
    }
}
