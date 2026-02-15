import Foundation

class CountriesStatisticsAPIClient {
    private let httpClient: HttpClient
    
    init(_ httpClient: HttpClient) {
        self.httpClient = httpClient
    }
    
    // MARK: - API Endpoints
    
    func fetchCountriesStatistics() async throws -> HttpResponse<[TopCountry]> {
        return try await httpClient.get(endpoint: "/api/v1/statistics/countries")
    }
}

