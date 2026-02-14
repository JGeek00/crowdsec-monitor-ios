import Foundation

class CrowdSecAPIClient {
    private let httpClient: HttpClient
    
    init(server: CSServer) {
        self.httpClient = HttpClient(server: server)
    }
    
    /// Initializer for testing connection before saving to database
    convenience init(
        connectionMethod: String,
        ipDomain: String,
        port: Int32?,
        path: String?,
        authMethod: String?,
        basicUser: String?,
        basicPassword: String?,
        bearerToken: String?
    ) {
        self.init(
            httpClient: HttpClient(
                connectionMethod: connectionMethod,
                ipDomain: ipDomain,
                port: port,
                path: path,
                authMethod: authMethod,
                basicUser: basicUser,
                basicPassword: basicPassword,
                bearerToken: bearerToken
            )
        )
    }
    
    private init(httpClient: HttpClient) {
        self.httpClient = httpClient
    }
    
    // MARK: - API Endpoints
    
    
    /// Check LAPI status
    func checkLAPIStatus() async throws -> HttpResponse<LAPIStatusResponse> {
        return try await httpClient.get(endpoint: "/api/v1/lapi-status")
    }
    
}
