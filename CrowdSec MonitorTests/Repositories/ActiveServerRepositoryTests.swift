@testable import CrowdSec_Monitor
import CoreData
import XCTest

@MainActor
final class ActiveServerRepositoryTests: XCTestCase {
    private var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        context = TestCoreData.makeContainer().viewContext
    }

    func testHasServerConfiguredFalseInitially() {
        let repo = ActiveServerRepository()
        XCTAssertFalse(repo.hasServerConfigured)
        XCTAssertNil(repo.currentServer)
        XCTAssertNil(repo.apiClient)
        XCTAssertNil(repo.webSocketClient)
    }

    func testActivateSetsProperties() {
        let repo = ActiveServerRepository()
        let server = TestCoreData.makeServer(in: context) as! CSServer

        let notificationExpectation = expectation(description: "serverDidChange")
        let token = NotificationCenter.default.addObserver(forName: .serverDidChange, object: nil, queue: nil) { _ in
            notificationExpectation.fulfill()
        }

        repo.activate(server)
        wait(for: [notificationExpectation], timeout: 1)

        XCTAssertEqual(repo.currentServer, server)
        XCTAssertNotNil(repo.apiClient)
        XCTAssertNotNil(repo.webSocketClient)
        XCTAssertTrue(repo.hasServerConfigured)

        NotificationCenter.default.removeObserver(token)
    }

    func testDeactivateClearsProperties() {
        let repo = ActiveServerRepository()
        let server = TestCoreData.makeServer(in: context) as! CSServer
        repo.activate(server)

        let notificationExpectation = expectation(description: "serverDidChange on deactivate")
        let token = NotificationCenter.default.addObserver(forName: .serverDidChange, object: nil, queue: nil) { _ in
            notificationExpectation.fulfill()
        }

        repo.deactivate()
        wait(for: [notificationExpectation], timeout: 1)

        XCTAssertNil(repo.currentServer)
        XCTAssertNil(repo.apiClient)
        XCTAssertNil(repo.webSocketClient)
        XCTAssertFalse(repo.hasServerConfigured)

        NotificationCenter.default.removeObserver(token)
    }

    func testActivateInvalidatesPreviousClient() {
        let repo = ActiveServerRepository()
        let server1 = TestCoreData.makeServer(in: context, domain: "server1.com") as! CSServer
        let server2 = TestCoreData.makeServer(in: context, domain: "server2.com") as! CSServer

        repo.activate(server1)
        let oldClient = repo.apiClient

        repo.activate(server2)
        // The old client should have been invalidated (session.invalidateAndCancel called)
        // We can't directly check invalidation, but verify the new server is active
        XCTAssertEqual(repo.currentServer, server2)
        XCTAssertTrue(repo.apiClient !== oldClient)
    }

    func testTaskSpawningAndCancellation() async {
        let repo = ActiveServerRepository()
        let server = TestCoreData.makeServer(in: context) as! CSServer
        repo.activate(server)

        let taskStarted = expectation(description: "task started")
        let task = repo.task {
            taskStarted.fulfill()
            do {
                try await Task.sleep(nanoseconds: 60_000_000_000) // 60s
            } catch {}
        }
        // Wait for the task to start
        await fulfillment(of: [taskStarted], timeout: 1)
        // Task should be running
        XCTAssertFalse(task.isCancelled)

        // Deactivate should cancel all tasks
        repo.deactivate()
        // Give a moment for cancellation to propagate
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertTrue(task.isCancelled)
    }
}
