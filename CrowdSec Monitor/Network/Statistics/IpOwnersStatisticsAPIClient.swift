import Foundation

class IpOwnersStatisticsAPIClient {
    private let httpClient: HttpClient
    
    init(_ httpClient: HttpClient) {
        self.httpClient = httpClient
    }
    
    // MARK: - API Endpoints
    
    func fetchIpOwnersStatistics() async throws -> HttpResponse<[TopIPOwner]> {
        return try await httpClient.get(endpoint: "/api/v1/statistics/ip-owners")
    }
    
}

