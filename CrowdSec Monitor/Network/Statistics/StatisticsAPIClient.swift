import Foundation

class StatisticsAPIClient {
    private let httpClient: HttpClient
    
    init(httpClient: HttpClient) {
        self.httpClient = httpClient
    }
    
    // MARK: - API Endpoints
    
    /// Fetch main statistics
    func fetchStatistics(amount: Int? = nil, since: Date? = nil) async throws -> HttpResponse<StatisticsResponse> {
        var queryParams: [String: String] = [:]
        
        if let amount = amount {
            queryParams["amount"] = String(amount)
        }
        
        if let since = since {
            queryParams["since"] = since.toYYYYMMDD()
        }
        
        return try await httpClient.get(endpoint: "/api/v1/statistics", queryParams: queryParams.isEmpty ? nil : queryParams)
    }
}

