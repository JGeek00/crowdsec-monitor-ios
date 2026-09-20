@testable import CrowdSec_Monitor
import CoreData

/// Injects an in-memory context into `ServersManagerRepository` via a minimal
/// override, so repository-backed tests never depend on the host app's real
/// CoreData store (which differs per simulator: an already-configured app has
/// servers, so "empty by default" assertions fail).
///
/// ponytail: instead of refactoring the production init() to accept a context,
/// we override the private viewContext initialization.
final class InjectServersManagerRepository: ServersManagerRepository {
    private let context: NSManagedObjectContext
    private let injectedActiveRepo: ActiveServerRepository

    init(activeServerRepository: ActiveServerRepository, context: NSManagedObjectContext) {
        self.context = context
        self.injectedActiveRepo = activeServerRepository
        super.init(activeServerRepository: activeServerRepository)
    }

    override func loadServers() {
        do {
            let fetchRequest: NSFetchRequest<CSServer> = CSServer.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "domain", ascending: true)]
            servers = try context.fetch(fetchRequest)
        } catch {
            servers = []
        }
    }

    override func createServer(
        name: String,
        connectionMethod: Enums.ConnectionMethod,
        ipDomain: String,
        port: Int32?,
        path: String?,
        authMethod: Enums.AuthMethod,
        basicUser: String?,
        basicPassword: String?,
        bearerToken: String?
    ) async throws {
        let server = CSServer(context: context)
        server.id = UUID()
        server.name = name
        server.http = connectionMethod.rawValue
        server.domain = ipDomain
        server.port = port ?? 0
        server.path = path
        server.authMethod = authMethod.rawValue
        server.basicUser = basicUser
        server.basicPassword = basicPassword
        server.bearerToken = bearerToken

        try context.save()
        servers.append(server)
        injectedActiveRepo.activate(server)
    }

    override func deleteServer(server: CSServer) -> Bool {
        do {
            let obj = try context.existingObject(with: server.objectID)
            context.delete(obj)
            try context.save()
            servers = servers.filter { $0 != server }

            if let next = servers.first(where: { $0.isDefaultServer == true }) ?? servers.first {
                injectedActiveRepo.activate(next)
            } else {
                injectedActiveRepo.deactivate()
            }
            return true
        } catch {
            return false
        }
    }

    override func setDefaultServer(_ server: CSServer) -> Bool {
        servers.first(where: { $0.isDefaultServer == true })?.isDefaultServer = nil
        server.isDefaultServer = true
        do {
            try context.save()
            loadServers()
            return true
        } catch {
            return false
        }
    }
}
