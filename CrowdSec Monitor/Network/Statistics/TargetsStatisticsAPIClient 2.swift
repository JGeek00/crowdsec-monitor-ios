import Foundation

class TargetsStatisticsAPIClient {
    private let httpClient: HttpClient
    
    init(_ httpClient: HttpClient) {
        self.httpClient = httpClient
    }
    
    // MARK: - API Endpoints
    
    func fetchTargetsStatistics() async throws -> HttpResponse<[TopTarget]> {
        return try await httpClient.get(endpoint: "/api/v1/statistics/targets")
    }
}

