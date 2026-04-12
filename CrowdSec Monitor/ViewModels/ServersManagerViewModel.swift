import Foundation
internal import CoreData
import SwiftUI

@MainActor
@Observable
class ServersManagerViewModel {
    static let shared = ServersManagerViewModel()

    var servers: [CSServer] = []
    var isLoading: Bool = true
    var errorMessage: String?

    @ObservationIgnored private let viewContext: NSManagedObjectContext

    private init() {
        self.viewContext = PersistenceController.shared.container.viewContext
        loadServers()
        activateInitialServer()
    }

    func loadServers() {
        do {
            let fetchRequest: NSFetchRequest<CSServer> = CSServer.fetchRequest()
            servers = try viewContext.fetch(fetchRequest)
        } catch {
            servers = []
        }
    }

    func createServer(
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
        let server = CSServer(context: viewContext)
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

        try viewContext.save()
        servers.append(server)

        ActiveServerViewModel.shared.activate(server)
    }

    @discardableResult
    func deleteServer(server: CSServer) -> Bool {
        do {
            viewContext.delete(server)
            try viewContext.save()
            servers = servers.filter { $0 != server }

            if let next = servers.first(where: { $0.isDefaultServer == true }) ?? servers.first {
                ActiveServerViewModel.shared.activate(next)
            } else {
                ActiveServerViewModel.shared.deactivate()
            }

            return true
        } catch {
            return false
        }
    }

    func changeCurrentServer(server: CSServer) {
        guard server != ActiveServerViewModel.shared.currentServer else { return }
        ActiveServerViewModel.shared.activate(server)
    }

    @discardableResult
    func setDefaultServer(_ server: CSServer) -> Bool {
        servers.first(where: { $0.isDefaultServer == true })?.isDefaultServer = nil
        server.isDefaultServer = true
        do {
            try viewContext.save()
            loadServers()
            return true
        } catch {
            return false
        }
    }

    func logout() {
        if let server = ActiveServerViewModel.shared.currentServer {
            deleteServer(server: server)
        }
    }

    private func activateInitialServer() {
        isLoading = true
        defer { isLoading = false }
        if let server = servers.first(where: { $0.isDefaultServer == true }) ?? servers.first {
            ActiveServerViewModel.shared.activate(server)
        }
    }
}
