class BlocklistsAPIClient {
    private let httpClient: HttpClient

    init(_ httpClient: HttpClient) {
        self.httpClient = httpClient
    }
    
    func fetchBlocklists() async throws -> HttpResponse<BlocklistsListResponse> {
        return try await httpClient.get(endpoint: "/api/v1/blocklists")
    }
}
