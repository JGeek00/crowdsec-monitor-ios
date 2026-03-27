import Foundation
internal import CoreData
import SwiftUI

@MainActor
@Observable
class AuthViewModel {
    static let shared = AuthViewModel()
    
    var isLoading: Bool = true
    var currentServer: CSServer?
    var servers: [CSServer] = []
    var apiClient: CrowdSecAPIClient?
    var errorMessage: String?
    
    private let viewContext: NSManagedObjectContext
    
    private init() {
        self.viewContext = PersistenceController.shared.container.viewContext
        
        loadServers()
        checkInstance()
    }
        
    var hasServerConfigured: Bool {
        currentServer != nil && apiClient != nil
    }
        
    func loadServers() {
        do {
            let fetchRequest: NSFetchRequest<CSServer> = CSServer.fetchRequest()
            let result = try viewContext.fetch(fetchRequest)
            servers = result
        } catch {
            servers = []
        }
    }

    func checkInstance() {
        isLoading = true
        errorMessage = nil
        
        let server = servers.first
        
        if let server = server {
            currentServer = server
            apiClient = CrowdSecAPIClient(server)
        } else {
            currentServer = nil
            apiClient = nil
        }
        
        isLoading = false
    }

    func saveServer(
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
        let server = servers.first ?? CSServer(context: viewContext)
        
        server.id = server.id
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
        
        checkInstance()
    }
    
    func deleteServer(server: CSServer) -> Bool {
        do {
            viewContext.delete(server)
            try viewContext.save()
            servers = servers.filter { $0.id != server.id }
            
            if server.id == currentServer?.id {
                currentServer = nil
                apiClient = nil
            }
            
            return true
        } catch {
            return false
        }
    }
    
    // MARK: - Error management
    
    /// Manage 401 error
    func handleUnauthorized() async {
        if let server = currentServer {
            _ = deleteServer(server: server)
        }
    }
    
    // MARK: - Helpers
    
    func logout() {
        if let server = currentServer {
            _ = deleteServer(server: server)
        }
    }
}
