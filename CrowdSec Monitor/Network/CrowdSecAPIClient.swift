import Foundation

class CrowdSecAPIClient {
    private let httpClient: HttpClient
    private let websocketClient: WebSocketClient
    
    let statistics: StatisticsAPIClient
    let alerts: AlertsAPIClient
    let decisions: DecisionsAPIClient
    let allowlists: AllowlistsAPIClient
    let blocklists: BlocklistsAPIClient
    
    init(_ server: CSServer) {
        self.httpClient = HttpClient(server: server)
        self.websocketClient = WebSocketClient(server: server)
        self.statistics = StatisticsAPIClient(self.httpClient)
        self.alerts = AlertsAPIClient(self.httpClient)
        self.decisions = DecisionsAPIClient(self.httpClient)
        self.allowlists = AllowlistsAPIClient(self.httpClient)
        self.blocklists = BlocklistsAPIClient(self.httpClient)
    }
    
    func checkApiStatus() async throws -> HttpResponse<APIStatusResponse> {
        return try await httpClient.get(endpoint: "/api/v1/status")
    }
    
    func streamApiStatus() -> AsyncThrowingStream<APIStatusResponse, Error> {
        return websocketClient.stream(endpoint: "/api/v1/status/ws", as: APIStatusResponse.self)
    }
    
    func disconnectApiStatusStream() {
        websocketClient.disconnect()
    }
}
