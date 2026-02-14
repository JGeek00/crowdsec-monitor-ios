import Foundation
internal import CoreData
import SwiftUI

@MainActor
@Observable
class AuthViewModel {
    static let shared = AuthViewModel()
    
    var isLoading: Bool = true
    var currentServer: CSServer?
    var apiClient: CrowdSecAPIClient?
    var errorMessage: String?
    
    private let viewContext: NSManagedObjectContext
    
    private init() {
        self.viewContext = PersistenceController.shared.container.viewContext
        
        checkInstance()
    }
        
    var hasServerConfigured: Bool {
        currentServer != nil && apiClient != nil
    }
        
    func checkInstance() {
        isLoading = true
        errorMessage = nil
        
        do {
            let server = try fetchServer()
            
            if let server = server {
                currentServer = server
                apiClient = CrowdSecAPIClient(server: server)
            } else {
                currentServer = nil
                apiClient = nil
                OnboardingViewModel.shared.openOnboarding()
            }
        } catch {
            currentServer = nil
            apiClient = nil
        }
        
        isLoading = false
    }
        
    private func fetchServer() throws -> CSServer? {
        let fetchRequest: NSFetchRequest<CSServer> = CSServer.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        let results = try viewContext.fetch(fetchRequest)
        return results.first
    }
    
    func saveServer(
        connectionMethod: Enums.ConnectionMethod,
        ipDomain: String,
        port: Int32?,
        path: String?,
        authMethod: Enums.AuthMethod,
        basicUser: String?,
        basicPassword: String?,
        bearerToken: String?
    ) async throws {
        let server = try fetchServer() ?? CSServer(context: viewContext)
        
        server.id = server.id ?? UUID()
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
    
    func deleteServer() throws {
        if let server = currentServer {
            viewContext.delete(server)
            try viewContext.save()
            
            currentServer = nil
            apiClient = nil
            OnboardingViewModel.shared.openOnboarding()
        }
    }
    
    // MARK: - Error management
    
    /// Manage 401 error
    func handleUnauthorized() async {
        do {
            try deleteServer()
        } catch {}
    }
    
    // MARK: - Helpers
    
    func logout() {
        do {
            try deleteServer()
        } catch {}
    }
}
