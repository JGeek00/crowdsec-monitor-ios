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
    
    /// Fetch alerts
    func fetchAlerts(requestParams: AlertsRequest) async throws -> HttpResponse<AlertsResponse> {
        var queryParams: [URLQueryItem] = []
        
        if let countries = requestParams.filters.countries {
            queryParams.append(contentsOf: countries.map { URLQueryItem(name: "country", value: $0) })
        }
        
        if let scenarios = requestParams.filters.scenarios {
            queryParams.append(contentsOf: scenarios.map { URLQueryItem(name: "scenario", value: $0) })
        }
        
        if let ipOwners = requestParams.filters.ipOwners {
            queryParams.append(contentsOf: ipOwners.map { URLQueryItem(name: "ipOwner", value: $0) })
        }
        
        if let targets = requestParams.filters.targets {
            queryParams.append(contentsOf: targets.map { URLQueryItem(name: "target", value: $0) })
        }
        
        // pagination
        queryParams.append(URLQueryItem(name: "offset", value: String(requestParams.pagination.offset)))
        queryParams.append(URLQueryItem(name: "limit", value: String(requestParams.pagination.limit)))
        
        return try await httpClient.get(endpoint: "/api/v1/alerts", queryParams: queryParams.isEmpty ? nil : queryParams)
    }
}
