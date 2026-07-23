import Foundation

class DecisionsAPIClient {
    private let httpClient: HttpClient
    
    init(_ httpClient: HttpClient) {
        self.httpClient = httpClient
    }
    
    func fetchDecisions(requestParams: DecisionsRequest) async throws -> HttpResponse<DecisionsListResponse> {
        var queryParams: [URLQueryItem] = []
        
        // ponytail: only send only_active=true; omit when false — the CrowdSec API treats
        // any presence of the param as "filter by active", so only_active=false still filters.
        if requestParams.filters.onlyActive == true {
            queryParams.append(URLQueryItem(name: "only_active", value: "true"))
        }
        
        // if let hideActiveDuplicated = requestParams.filters.hideActiveDuplicated {
        //    queryParams.append(URLQueryItem(name: "hide_active_duplicated", value: String(hideActiveDuplicated)))
        // }
        
        // pagination
        queryParams.append(URLQueryItem(name: "offset", value: String(requestParams.pagination.offset)))
        queryParams.append(URLQueryItem(name: "limit", value: String(requestParams.pagination.limit)))
        
        return try await httpClient.get(endpoint: "/api/v1/decisions", queryParams: queryParams.isEmpty ? nil : queryParams)
    }
    
    func fetchDecisionDetails(decisionId: Int) async throws -> HttpResponse<DecisionItemResponse> {
        return try await httpClient.get(endpoint: "/api/v1/decisions/\(decisionId)")
    }
    
    func createDecision(body: CreateDecisionRequest) async throws -> HttpResponse<EmptyResponse> {
        return try await httpClient.post(endpoint: "/api/v1/decisions", body: body)
    }
    
    func deleteDecision(decisionId: Int) async throws -> HttpResponse<EmptyResponse> {
        return try await httpClient.delete(endpoint: "/api/v1/decisions/\(decisionId)")
    }

    func fetchDecisionsByIP(requestParams: DecisionsRequest) async throws -> HttpResponse<DecisionsByIPResponse> {
        var queryParams: [URLQueryItem] = []

        if requestParams.filters.onlyActive == true {
            queryParams.append(URLQueryItem(name: "only_active", value: "true"))
        }

        queryParams.append(URLQueryItem(name: "offset", value: String(requestParams.pagination.offset)))
        queryParams.append(URLQueryItem(name: "limit", value: String(requestParams.pagination.limit)))

        return try await httpClient.get(endpoint: "/api/v1/decisions/by-ip", queryParams: queryParams.isEmpty ? nil : queryParams)
    }

    func fetchDecisionsByIPDetail(ip: String, onlyActive: Bool? = nil) async throws -> HttpResponse<DecisionsByIPDetailResponse> {
        var queryParams: [URLQueryItem] = []

        if onlyActive == true {
            queryParams.append(URLQueryItem(name: "only_active", value: "true"))
        }

        return try await httpClient.get(endpoint: "/api/v1/decisions/by-ip/\(ip)", queryParams: queryParams.isEmpty ? nil : queryParams)
    }
}
