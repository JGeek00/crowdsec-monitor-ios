@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class ServerSettingsViewModelTests: XCTestCase {
    func testServersEmptyByDefault() {
        let repo = ServersManagerRepository(activeServerRepository: MockActiveServerRepository())
        let sut = ServerSettingsViewModel(serversManagerRepository: repo)
        XCTAssertTrue(sut.servers.isEmpty)
    }
}
