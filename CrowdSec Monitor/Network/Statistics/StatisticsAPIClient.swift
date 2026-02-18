import Foundation

class StatisticsAPIClient {
    private let httpClient: HttpClient
    
    let countries: CountriesStatisticsAPIClient
    let ipOwners: IpOwnersStatisticsAPIClient
    let scenarios: ScenariosStatisticsAPIClient
    let targets: TargetsStatisticsAPIClient
    
    init(_ httpClient: HttpClient) {
        self.httpClient = httpClient
        self.countries = CountriesStatisticsAPIClient(self.httpClient)
        self.ipOwners = IpOwnersStatisticsAPIClient(self.httpClient)
        self.scenarios = ScenariosStatisticsAPIClient(self.httpClient)
        self.targets = TargetsStatisticsAPIClient(self.httpClient)
    }
    
    // MARK: - API Endpoints
    
    /// Fetch main statistics
    func fetchStatistics(amount: Int? = nil, since: Date? = nil) async throws -> HttpResponse<StatisticsResponse> {
        var queryParams: [URLQueryItem] = []
        
        if let amount = amount {
            queryParams.append(URLQueryItem(name: "amount", value: String(amount)))
        }
        
        if let since = since {
            queryParams.append(URLQueryItem(name: "since", value: since.toYYYYMMDD()))
        }
        
        return try await httpClient.get(endpoint: "/api/v1/statistics", queryParams: queryParams.isEmpty ? nil : queryParams)
    }
}

