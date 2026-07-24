@testable import CrowdSec_Monitor
import CoreData
import XCTest

@MainActor
final class ServerListItemViewModelTests: XCTestCase {
    private var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        context = TestCoreData.makeContainer().viewContext
    }

    func testCurrentServerNilByDefault() {
        let activeRepo = MockActiveServerRepository()
        let serversRepo = ServersManagerRepository(activeServerRepository: activeRepo)
        let sut = ServerListItemViewModel(
            serversManagerRepository: serversRepo,
            activeServerRepository: activeRepo
        )
        XCTAssertNil(sut.currentServer)
    }
}
