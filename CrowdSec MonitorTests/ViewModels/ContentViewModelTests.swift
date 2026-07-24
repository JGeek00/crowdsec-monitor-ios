@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class ContentViewModelTests: XCTestCase {
    func testHasServerConfiguredFalseByDefault() {
        let activeRepo = MockActiveServerRepository()
        let sut = ContentViewModel(
            activeServerRepository: activeRepo,
            serviceStatusRepository: ServiceStatusRepository(activeServerRepository: activeRepo)
        )
        XCTAssertFalse(sut.hasServerConfigured)
    }

    func testHasServerConfiguredTrue() {
        let activeRepo = MockActiveServerRepository(mockApiClient: CrowdSecAPIClient(TestCoreData.makeServer(in: TestCoreData.makeContainer().viewContext) as! CSServer))
        let sut = ContentViewModel(
            activeServerRepository: activeRepo,
            serviceStatusRepository: ServiceStatusRepository(activeServerRepository: activeRepo)
        )
        XCTAssertTrue(sut.hasServerConfigured)
    }
}
