@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class SettingsViewModelTests: XCTestCase {
    func testHasNewVersionFalseByDefault() {
        let activeRepo = MockActiveServerRepository()
        let statusRepo = ServiceStatusRepository(activeServerRepository: activeRepo)
        let sut = SettingsViewModel(serviceStatusRepository: statusRepo)
        XCTAssertFalse(sut.hasNewVersion)
    }
}
