import Foundation

class ScenariosStatisticsAPIClient {
    private let httpClient: HttpClient
    
    init(_ httpClient: HttpClient) {
        self.httpClient = httpClient
    }
    
    // MARK: - API Endpoints
    
    func fetchScenariosStatistics() async throws -> HttpResponse<[TopScenario]> {
        return try await httpClient.get(endpoint: "/api/v1/statistics/scenarios")
    }
}

