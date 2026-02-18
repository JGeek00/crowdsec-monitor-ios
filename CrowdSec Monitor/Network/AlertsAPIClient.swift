import Foundation

class AlertsAPIClient {
    private let httpClient: HttpClient
    
    init(_ httpClient: HttpClient) {
        self.httpClient = httpClient
    }
    
    /// Fetch alerts
    func fetchAlerts(requestParams: AlertsRequest) async throws -> HttpResponse<AlertsListResponse> {
        var queryParams: [URLQueryItem] = []
        
        if !requestParams.filters.countries.isEmpty {
            queryParams.append(contentsOf: requestParams.filters.countries.map { URLQueryItem(name: "country", value: $0) })
        }
        
        if !requestParams.filters.scenarios.isEmpty {
            queryParams.append(contentsOf: requestParams.filters.scenarios.map { URLQueryItem(name: "scenario", value: $0) })
        }
        
        if !requestParams.filters.ipOwners.isEmpty {
            queryParams.append(contentsOf: requestParams.filters.ipOwners.map { URLQueryItem(name: "ipOwner", value: $0) })
        }
        
        if !requestParams.filters.targets.isEmpty {
            queryParams.append(contentsOf: requestParams.filters.targets.map { URLQueryItem(name: "target", value: $0) })
        }
        
        // pagination
        queryParams.append(URLQueryItem(name: "offset", value: String(requestParams.pagination.offset)))
        queryParams.append(URLQueryItem(name: "limit", value: String(requestParams.pagination.limit)))
        
        return try await httpClient.get(endpoint: "/api/v1/alerts", queryParams: queryParams.isEmpty ? nil : queryParams)
    }
    
    /// Fetch alert details
    func fetchAlertDetails(alertId: Int) async throws -> HttpResponse<AlertDetailsResponse> {
        return try await httpClient.get(endpoint: "/api/v1/alerts/\(alertId)")
    }
}
