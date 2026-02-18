import Foundation

class DecisionsAPIClient {
    private let httpClient: HttpClient
    
    init(_ httpClient: HttpClient) {
        self.httpClient = httpClient
    }
    
    /// Fetch alerts
    func fetchDecisions(requestParams: DecisionsRequest) async throws -> HttpResponse<DecisionsListResponse> {
        var queryParams: [URLQueryItem] = []
        
        if let onlyActive = requestParams.filters.onlyActive {
            queryParams.append(URLQueryItem(name: "only_active", value: String(onlyActive)))
        }
        
        if let hideActiveDuplicated = requestParams.filters.hideActiveDuplicated {
            queryParams.append(URLQueryItem(name: "hide_active_duplicated", value: String(hideActiveDuplicated)))
        }
        
        // pagination
        queryParams.append(URLQueryItem(name: "offset", value: String(requestParams.pagination.offset)))
        queryParams.append(URLQueryItem(name: "limit", value: String(requestParams.pagination.limit)))
        
        return try await httpClient.get(endpoint: "/api/v1/decisions", queryParams: queryParams.isEmpty ? nil : queryParams)
    }
    
    /// Fetch decision details
    func fetchDecisionDetails(decisionId: Int) async throws -> HttpResponse<DecisionItemResponse> {
        return try await httpClient.get(endpoint: "/api/v1/decisions/\(decisionId)")
    }
}
