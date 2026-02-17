import Foundation

class CrowdSecAPIClient {
    private let httpClient: HttpClient
    
    let statistics: StatisticsAPIClient
    let alerts: AlertsAPIClient
    let decisions: DecisionsAPIClient
    
    init(_ server: CSServer) {
        self.httpClient = HttpClient(server: server)
        self.statistics = StatisticsAPIClient(self.httpClient)
        self.alerts = AlertsAPIClient(self.httpClient)
        self.decisions = DecisionsAPIClient(self.httpClient)
    }
    
    /// Check LAPI status
    func checkLAPIStatus() async throws -> HttpResponse<LAPIStatusResponse> {
        return try await httpClient.get(endpoint: "/api/v1/lapi-status")
    }
}
