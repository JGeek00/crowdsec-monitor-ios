import Foundation

class BlocklistsAPIClient {
    private let httpClient: HttpClient

    init(_ httpClient: HttpClient) {
        self.httpClient = httpClient
    }
    
    func fetchBlocklists(requestParams: BlocklistsRequest? = nil) async throws -> HttpResponse<BlocklistsListResponse> {
        var queryParams: [URLQueryItem] = []
        
        if let value = requestParams?.limit {
            queryParams.append(URLQueryItem(name: "limit", value: String(value)))
        }
        if let value = requestParams?.offset {
            queryParams.append(URLQueryItem(name: "offset", value: String(value)))
        }
        
        return try await httpClient.get(endpoint: "/api/v1/blocklists", queryParams: queryParams)
    }
    
    func fetchBlocklistData(blocklistId: String) async throws -> HttpResponse<BlocklistDataResponse> {
        let queryParams: [URLQueryItem] = [
            URLQueryItem(name: "include_ips", value: "ip_string"),
        ]
        
        return try await httpClient.get(endpoint: "/api/v1/blocklists/\(blocklistId)", queryParams: queryParams)
    }
    
    func fetchBlocklistIps(blocklistId: String) async throws -> HttpResponse<BlocklistIpsResponse> {
        let queryParams: [URLQueryItem] = [
            URLQueryItem(name: "unpaged", value: "true"),
            URLQueryItem(name: "ip_string", value: "true"),
        ]
        
        return try await httpClient.get(endpoint: "/api/v1/blocklists/\(blocklistId)/ips", queryParams: queryParams)
    }
    
    func addBlocklist(body: AddBlocklistRequestBody) async throws -> HttpResponse<EmptyResponse> {
        return try await httpClient.post(endpoint: "/api/v1/blocklists", body: body)
    }
    
    func toggleBlocklist(params: ToggleBlocklistRequestParams, body: ToggleBlocklistRequestBody) async throws -> HttpResponse<EmptyResponse> {
        return try await httpClient.post(endpoint: "/api/v1/blocklists/\(params.blocklistId)/enabled", body: body)
    }
    
    func deleteBlocklist(params: DeleteBlocklistRequestParams) async throws -> HttpResponse<EmptyResponse> {
        return try await httpClient.delete(endpoint: "/api/v1/blocklists/\(params.blocklistId)")
    }
    
    func checkIps(_ body: BlocklistsCheckIPsRequest) async throws -> HttpResponse<BlocklistsCheckIPsResponse> {
        return try await httpClient.post(endpoint: "/api/v1/blocklists/check", body: body)
    }
    
    func checkDomain(_ body: BlocklistsCheckDomainRequest) async throws -> HttpResponse<BlocklistsCheckDomainResponse> {
        return try await httpClient.post(endpoint: "/api/v1/blocklists/check-domain", body: body)
    }
}
