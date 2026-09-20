@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class ServerSettingsViewModelTests: XCTestCase {
    func testServersEmptyByDefault() {
        // In-memory context: the host app's real store may contain servers
        // (e.g. on an already-configured simulator), which would break the
        // "empty by default" assertion.
        let repo = InjectServersManagerRepository(
            activeServerRepository: MockActiveServerRepository(),
            context: TestCoreData.makeContainer().viewContext
        )
        let sut = ServerSettingsViewModel(serversManagerRepository: repo)
        XCTAssertTrue(sut.servers.isEmpty)
    }
}
