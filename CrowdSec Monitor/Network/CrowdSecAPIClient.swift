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
    
    func checkCredentials() async throws -> HttpResponse<EmptyResponse> {
        return try await httpClient.get(endpoint: "/api/v1/check-credentials")
    }
    
    func checkApiStatus() async throws -> HttpResponse<APIStatusResponse> {
        return try await httpClient.get(endpoint: "/api/v1/status")
    }
    
    func streamApiStatus() -> AsyncThrowingStream<APIStatusResponse, Error> {
        return websocketClient.stream(endpoint: "/api/v1/status", as: APIStatusResponse.self)
    }
    
    func disconnectApiStatusStream() {
        websocketClient.disconnect()
    }

    /// Tears down all network resources owned by this client.
    /// Call this before discarding the instance (e.g. when switching servers).
    ///
    /// `session.invalidateAndCancel()` immediately cancels every in-flight HTTP
    /// request with `NSURLErrorCancelled`, so ViewModels don't need an explicit
    /// "cancel pending requests" call — their `catch` blocks already handle it.
    /// The per-ViewModel `currentServer?.id` guards act as a secondary safety net
    /// for tasks that captured the new client before `reset()` ran.
    func invalidate() {
        websocketClient.disconnect()
        httpClient.session.invalidateAndCancel()
    }
}
