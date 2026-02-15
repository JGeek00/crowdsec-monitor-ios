import Foundation

class ScenariesStatisticsAPIClient {
    private let httpClient: HttpClient
    
    init(_ httpClient: HttpClient) {
        self.httpClient = httpClient
    }
    
    // MARK: - API Endpoints
    
    func fetchScenariesStatistics() async throws -> HttpResponse<[TopScenario]> {
        return try await httpClient.get(endpoint: "/api/v1/statistics/scenarios")
    }
}

