import Foundation

class CrowdSecAPIClient {
    private let httpClient: HttpClient
    
    let statistics: StatisticsAPIClient
    let alerts: AlertsAPIClient
    let decisions: DecisionsAPIClient
    let allowlists: AllowlistsAPIClient
    let blocklists: BlocklistsAPIClient
    
    init(_ server: CSServer) {
        self.httpClient = HttpClient(server: server)
        self.statistics = StatisticsAPIClient(self.httpClient)
        self.alerts = AlertsAPIClient(self.httpClient)
        self.decisions = DecisionsAPIClient(self.httpClient)
        self.allowlists = AllowlistsAPIClient(self.httpClient)
        self.blocklists = BlocklistsAPIClient(self.httpClient)
    }
    
    func checkApiStatus() async throws -> HttpResponse<ApiStatusResponse> {
        return try await httpClient.get(endpoint: "/api/v1/status")
    }
}
