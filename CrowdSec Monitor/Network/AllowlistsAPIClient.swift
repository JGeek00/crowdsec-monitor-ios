class AllowlistsAPIClient {
    private let httpClient: HttpClient

    init(_ httpClient: HttpClient) {
        self.httpClient = httpClient
    }
    
    func fetchAllowlists() async throws -> HttpResponse<AllowlistsListResponse> {
        return try await httpClient.get(endpoint: "/api/v1/allowlists")
    }
    
    func checkIps(_ body: CheckIPsRequest) async throws -> HttpResponse<CheckIPsResponse> {
        return try await httpClient.post(endpoint: "/api/v1/allowlists/check", body: body)
    }
}
