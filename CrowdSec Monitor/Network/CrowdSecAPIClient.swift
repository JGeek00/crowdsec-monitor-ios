import Foundation

class CrowdSecAPIClient {
    private let httpClient: HttpClient
    
    let statistics: StatisticsAPIClient
    
    init(_ server: CSServer) {
        self.httpClient = HttpClient(server: server)
        self.statistics = StatisticsAPIClient(self.httpClient)
    }
    
    /// Check LAPI status
    func checkLAPIStatus() async throws -> HttpResponse<LAPIStatusResponse> {
        return try await httpClient.get(endpoint: "/api/v1/lapi-status")
    }
}
