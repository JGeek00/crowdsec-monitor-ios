@testable import CrowdSec_Monitor
import CoreData
import XCTest

@MainActor
final class ServersManagerRepositoryTests: XCTestCase {
    private var context: NSManagedObjectContext!
    private var activeRepo: ActiveServerRepository!

    override func setUp() {
        super.setUp()
        context = TestCoreData.makeContainer().viewContext
        activeRepo = ActiveServerRepository()
    }

    /// Create a ServersManagerRepository backed by the in-memory context
    private func makeRepo() -> ServersManagerRepository {
        // ponytail: ServersManagerRepository uses PersistenceController.shared.viewContext
        // in production. For tests we need to inject the in-memory context.
        return InjectServersManagerRepository(activeServerRepository: activeRepo, context: context)
    }

    func testLoadServersInitiallyEmpty() {
        let repo = makeRepo()
        XCTAssertTrue(repo.servers.isEmpty)
    }

    func testLoadServersReturnsSeeded() {
        // Seed servers directly via context
        let _ = TestCoreData.makeServer(in: context, domain: "a.com")
        let _ = TestCoreData.makeServer(in: context, domain: "b.com")
        try? context.save()

        let repo = makeRepo()
        repo.loadServers()
        XCTAssertEqual(repo.servers.count, 2)
    }

    func testCreateServerAndActivate() async throws {
        let repo = makeRepo()
        try await repo.createServer(
            name: "Test",
            connectionMethod: .https,
            ipDomain: "test.local",
            port: 443,
            path: "/api",
            authMethod: .bearer,
            basicUser: nil,
            basicPassword: nil,
            bearerToken: "token"
        )
        XCTAssertEqual(repo.servers.count, 1)
        XCTAssertEqual(repo.servers.first?.name, "Test")
        // Server should be activated
        XCTAssertNotNil(activeRepo.currentServer)
        XCTAssertEqual(activeRepo.currentServer?.domain, "test.local")
    }

    func testDeleteServerActivatesNext() {
        let repo = makeRepo()
        let server1 = TestCoreData.makeServer(in: context, domain: "a.com") as! CSServer
        let server2 = TestCoreData.makeServer(in: context, domain: "b.com") as! CSServer
        try? context.save()
        repo.loadServers()

        activeRepo.activate(server1)

        let result = repo.deleteServer(server: server1)
        XCTAssertTrue(result)
        XCTAssertEqual(repo.servers.count, 1)
        XCTAssertEqual(activeRepo.currentServer?.domain, "b.com")
    }

    func testDeleteLastServerDeactivates() {
        let repo = makeRepo()
        let server = TestCoreData.makeServer(in: context, domain: "only.com") as! CSServer
        try? context.save()
        repo.loadServers()
        activeRepo.activate(server)

        let result = repo.deleteServer(server: server)
        XCTAssertTrue(result)
        XCTAssertTrue(repo.servers.isEmpty)
        XCTAssertNil(activeRepo.currentServer)
    }

    func testDeleteServerFailureReturnsFalse() {
        let repo = makeRepo()
        // Server not in context — delete will fail
        let orphanServer = TestCoreData.makeServer(in: TestCoreData.makeContainer().viewContext, domain: "orphan.com") as! CSServer
        // Remove from context by not saving
        let result = repo.deleteServer(server: orphanServer)
        XCTAssertFalse(result)
    }

    func testChangeCurrentServerNoOpWhenSame() {
        let repo = makeRepo()
        let server = TestCoreData.makeServer(in: context, domain: "same.com") as! CSServer
        activeRepo.activate(server)
        let originalClient = activeRepo.apiClient

        repo.changeCurrentServer(server: server)
        // Same server — apiClient should remain the same (not re-activated)
        XCTAssertTrue(activeRepo.apiClient === originalClient)
    }

    func testSetDefaultServerFlipsFlag() {
        let repo = makeRepo()
        let s1 = TestCoreData.makeServer(in: context, domain: "a.com") as! CSServer
        let s2 = TestCoreData.makeServer(in: context, domain: "b.com") as! CSServer
        try? context.save()
        repo.loadServers()

        let result = repo.setDefaultServer(s2)
        XCTAssertTrue(result)
        // Reload to get updated flags
        repo.loadServers()
        let updatedS2 = repo.servers.first { $0.domain == "b.com" }
        XCTAssertEqual(updatedS2?.isDefaultServer, true)
    }

    func testLogoutDeletesCurrent() {
        let repo = makeRepo()
        let server = TestCoreData.makeServer(in: context, domain: "logout.com") as! CSServer
        try? context.save()
        repo.loadServers()
        activeRepo.activate(server)

        repo.logout()
        XCTAssertTrue(repo.servers.isEmpty)
        XCTAssertNil(activeRepo.currentServer)
    }

    func testActivateInitialServerActivatesDefault() {
        let repo = makeRepo()
        let s1 = TestCoreData.makeServer(in: context, domain: "default.com", isDefaultServer: true) as! CSServer
        let s2 = TestCoreData.makeServer(in: context, domain: "other.com") as! CSServer
        try? context.save()
        repo.loadServers()

        repo.activateInitialServer()
        XCTAssertEqual(activeRepo.currentServer?.domain, "default.com")
    }

    func testActivateInitialServerActivatesFirstIfNoDefault() {
        let repo = makeRepo()
        let s1 = TestCoreData.makeServer(in: context, domain: "first.com") as! CSServer
        let s2 = TestCoreData.makeServer(in: context, domain: "second.com") as! CSServer
        try? context.save()
        repo.loadServers()

        repo.activateInitialServer()
        XCTAssertEqual(activeRepo.currentServer?.domain, "first.com")
    }
}

