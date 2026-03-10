import Foundation

class BlocklistsAPIClient {
    private let httpClient: HttpClient

    init(_ httpClient: HttpClient) {
        self.httpClient = httpClient
    }
    
    func fetchBlocklists() async throws -> HttpResponse<BlocklistsListResponse> {
        return try await httpClient.get(endpoint: "/api/v1/blocklists")
    }
    
    func fetchBlocklistData(blocklistId: Int) async throws -> HttpResponse<BlocklistDataResponse> {
        let queryParams: [URLQueryItem] = [
            URLQueryItem(name: "include_ips", value: "ip_string"),
        ]
        
        return try await httpClient.get(endpoint: "/api/v1/blocklists/\(blocklistId)", queryParams: queryParams)
    }
    
    func fetchBlocklistIps(blocklistId: Int) async throws -> HttpResponse<BlocklistIpsResponse> {
        let queryParams: [URLQueryItem] = [
            URLQueryItem(name: "unpaged", value: "true"),
            URLQueryItem(name: "ip_string", value: "true"),
        ]
        
        return try await httpClient.get(endpoint: "/api/v1/blocklists/\(blocklistId)/ips", queryParams: queryParams)
    }
}
