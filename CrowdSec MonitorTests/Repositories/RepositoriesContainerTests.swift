@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class RepositoriesContainerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        RepositoriesContainer.reset()
    }

    override func tearDown() {
        RepositoriesContainer.reset()
        super.tearDown()
    }

    func testSharedExposesRepositories() {
        let container = RepositoriesContainer.shared
        XCTAssertNotNil(container.activeServerRepository)
        XCTAssertNotNil(container.serversManagerRepository)
        XCTAssertNotNil(container.serviceStatusRepository)
    }

    func testResetRecreatesContainer() {
        let original = RepositoriesContainer.shared
        let originalID = ObjectIdentifier(original)

        let resetExpectation = expectation(description: "repositoriesDidReset")
        let token = NotificationCenter.default.addObserver(forName: .repositoriesDidReset, object: nil, queue: nil) { _ in
            resetExpectation.fulfill()
        }

        RepositoriesContainer.reset()
        wait(for: [resetExpectation], timeout: 1)

        let newContainer = RepositoriesContainer.shared
        let newID = ObjectIdentifier(newContainer)
        XCTAssertNotEqual(originalID, newID)

        NotificationCenter.default.removeObserver(token)
    }

    func testResetPostsNotification() {
        let expectation = self.expectation(forNotification: .repositoriesDidReset, object: nil, notificationCenter: .default)
        RepositoriesContainer.reset()
        wait(for: [expectation], timeout: 1)
    }
}
