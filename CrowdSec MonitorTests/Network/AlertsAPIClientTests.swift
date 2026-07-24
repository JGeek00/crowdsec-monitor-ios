@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class AlertsAPIClientTests: XCTestCase {
    private var mockHttp: MockHttpClient!

    override func setUp() {
        super.setUp()
        mockHttp = MockHttpClient()
    }

    override func tearDown() {
        mockHttp = nil
        super.tearDown()
    }

    private func makeClient() -> AlertsAPIClient {
        AlertsAPIClient(mockHttp)
    }

    func testFetchAlertsQueryParams() async throws {
        let client = makeClient()
        let params = AlertsRequest(
            filters: AlertsRequestFilters(countries: ["ES"], scenarios: ["test-scenario"], ipOwners: ["owner1"], targets: ["target1"]),
            pagination: AlertsRequestPagination(offset: 0, limit: 25)
        )
        mockHttp.stubbedResponseData = try JSONSerialization.data(withJSONObject: [
            "filtering": ["countries": [], "scenarios": [], "ipOwners": [], "targets": []],
            "items": [],
            "pagination": ["page": 0, "amount": 0, "total": 0]
        ])
        let _: HttpResponse<AlertsListResponse> = try await client.fetchAlerts(requestParams: params)
        // MockHttpClient captures the endpoint & query params sent to HttpClient
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/alerts")
        let query = mockHttp.capturedQueryParams ?? []
        XCTAssertTrue(query.contains { $0.name == "country" && $0.value == "ES" })
        XCTAssertTrue(query.contains { $0.name == "scenario" && $0.value == "test-scenario" })
        XCTAssertTrue(query.contains { $0.name == "ipOwner" && $0.value == "owner1" })
        XCTAssertTrue(query.contains { $0.name == "target" && $0.value == "target1" })
        XCTAssertTrue(query.contains { $0.name == "offset" && $0.value == "0" })
        XCTAssertTrue(query.contains { $0.name == "limit" && $0.value == "25" })
    }

    func testFetchAlertsEmptyFilters() async throws {
        let client = makeClient()
        let params = AlertsRequest(
            filters: AlertsRequestFilters(countries: [], scenarios: [], ipOwners: [], targets: []),
            pagination: AlertsRequestPagination(offset: 0, limit: 10)
        )
        mockHttp.stubbedResponseData = try JSONSerialization.data(withJSONObject: [
            "filtering": ["countries": [], "scenarios": [], "ipOwners": [], "targets": []],
            "items": [],
            "pagination": ["page": 0, "amount": 0, "total": 0]
        ])
        let _: HttpResponse<AlertsListResponse> = try await client.fetchAlerts(requestParams: params)
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/alerts")
        let query = mockHttp.capturedQueryParams ?? []
        XCTAssertFalse(query.contains { $0.name == "country" })
        XCTAssertFalse(query.contains { $0.name == "scenario" })
        XCTAssertTrue(query.contains { $0.name == "offset" && $0.value == "0" })
        XCTAssertTrue(query.contains { $0.name == "limit" && $0.value == "10" })
    }

    func testFetchAlertDetailsEndpoint() async throws {
        let client = makeClient()
        mockHttp.stubbedResponseData = try JSONSerialization.data(withJSONObject: [
            "id": 1, "uuid": "t", "scenario": "t", "scenario_version": "1",
            "scenario_hash": "a", "message": "t", "capacity": 0,
            "leakspeed": "1s", "simulated": false, "remediation": false,
            "events_count": 0, "machine_id": "m",
            "source": ["scope": "ip", "value": "1.2.3.4"],
            "meta": [], "events": [], "decisions": [],
            "crowdsec_created_at": "2026-01-01T00:00:00.000Z",
            "start_at": "2026-01-01T00:00:00.000Z",
            "stop_at": "2026-01-01T00:00:00.000Z"
        ])
        let _: HttpResponse<AlertDetailsResponse> = try await client.fetchAlertDetails(alertId: 42)
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/alerts/42")
    }

    func testDeleteAlertEndpoint() async throws {
        let client = makeClient()
        mockHttp.stubbedResponseData = Data("{}".utf8)
        let _: HttpResponse<EmptyResponse> = try await client.deleteAlert(alertId: 7)
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/alerts/7")
    }
}
