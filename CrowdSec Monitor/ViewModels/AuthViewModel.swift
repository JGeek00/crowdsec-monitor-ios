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
        
        let server = servers.first(where: { $0.isDefaultServer == true }) ?? servers.first
        
        if let server = server {
            currentServer = server
            apiClient = CrowdSecAPIClient(server)
        } else {
            currentServer = nil
            apiClient = nil
        }
        
        isLoading = false
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
        
        currentServer = server
        apiClient = CrowdSecAPIClient(server)
        Task {
            await ServerStatusViewModel.shared.fetchStatus()
        }
    }
    
    func deleteServer(server: CSServer) -> Bool {
        do {
            viewContext.delete(server)
            try viewContext.save()
            servers = servers.filter { $0 != server }
            
            if server == currentServer {
                currentServer = nil
                apiClient = nil
            }
            
            return true
        } catch {
            return false
        }
    }
    
    func changeCurrentServer(server: CSServer) {
        if server == currentServer {
            return
        }
        
        currentServer = server
        apiClient = CrowdSecAPIClient(server)
        
        // Reset all view models so they reload data for the new server
        ServerStatusViewModel.shared.reset()
        DashboardViewModel.shared.reset()
        AlertsListViewModel.shared.reset()
        DecisionsListViewModel.shared.reset()
        BlocklistsListViewModel.shared.reset()
        AllowlistsListViewModel.shared.reset()
        
        Task {
            await ServerStatusViewModel.shared.fetchStatus()
        }
    }
    
    func setDefaultServer(_ server: CSServer) -> Bool {
        if let current = servers.first(where: { $0.isDefaultServer == true }) {
            current.isDefaultServer = nil
        }
        
        server.isDefaultServer = true
        
        do {
            try viewContext.save()
            loadServers()
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
