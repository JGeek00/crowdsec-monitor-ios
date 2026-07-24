@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class DecisionsAPIClientTests: XCTestCase {
    private var mockHttp: MockHttpClient!

    override func setUp() {
        super.setUp()
        mockHttp = MockHttpClient()
    }

    override func tearDown() {
        mockHttp = nil
        super.tearDown()
    }

    private func makeClient() -> DecisionsAPIClient {
        DecisionsAPIClient(mockHttp)
    }

    private func decisionsListJSON() -> Data {
        try! JSONSerialization.data(withJSONObject: [
            "filtering": ["countries": [], "ipOwners": []],
            "items": [[
                "id": 1, "alert_id": 1, "origin": "", "type": "", "scope": "",
                "value": "", "expiration": "", "scenario": "", "simulated": false,
                "source": ["scope": "", "value": ""], "crowdsec_created_at": ""
            ]],
            "pagination": ["page": 1, "amount": 0, "total": 0]
        ])
    }

    func testFetchDecisionsOnlyActiveTrue() async throws {
        let client = makeClient()
        let params = DecisionsRequest(filters: DecisionsRequestFilters(onlyActive: true), pagination: DecisionsRequestPagination(offset: 0, limit: 50))
        mockHttp.stubbedResponseData = decisionsListJSON()
        let _: HttpResponse<DecisionsListResponse> = try await client.fetchDecisions(requestParams: params)
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/decisions")
        let query = mockHttp.capturedQueryParams ?? []
        XCTAssertTrue(query.contains { $0.name == "only_active" && $0.value == "true" })
        XCTAssertTrue(query.contains { $0.name == "offset" && $0.value == "0" })
        XCTAssertTrue(query.contains { $0.name == "limit" && $0.value == "50" })
    }

    func testFetchDecisionsOnlyActiveFalseOmitted() async throws {
        let client = makeClient()
        let params = DecisionsRequest(filters: DecisionsRequestFilters(onlyActive: false), pagination: DecisionsRequestPagination(offset: 0, limit: 50))
        mockHttp.stubbedResponseData = decisionsListJSON()
        let _: HttpResponse<DecisionsListResponse> = try await client.fetchDecisions(requestParams: params)
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/decisions")
        let query = mockHttp.capturedQueryParams ?? []
        XCTAssertFalse(query.contains { $0.name == "only_active" })
    }

    func testFetchDecisionsByIP() async throws {
        let client = makeClient()
        let params = DecisionsRequest(filters: DecisionsRequestFilters(onlyActive: true), pagination: DecisionsRequestPagination(offset: 0, limit: 10))
        mockHttp.stubbedResponseData = try JSONSerialization.data(withJSONObject: [
            "filtering": ["countries": [], "ipOwners": []],
            "groups": [["ip": "", "range": "", "active_decisions": 0, "total_decisions": 0]],
            "pagination": ["page": 1, "amount": 0, "total": 0]
        ])
        let _: HttpResponse<DecisionsByIPResponse> = try await client.fetchDecisionsByIP(requestParams: params)
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/decisions/by-ip")
    }

    func testFetchDecisionsByIPDetail() async throws {
        let client = makeClient()
        mockHttp.stubbedResponseData = try JSONSerialization.data(withJSONObject: [
            "ip": "192.168.1.1",
            "active_decisions": 0,
            "total_decisions": 0,
            "decisions": []
        ])
        let _: HttpResponse<DecisionsByIPDetailResponse> = try await client.fetchDecisionsByIPDetail(ip: "192.168.1.1")
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/decisions/by-ip/192.168.1.1")
    }

    func testFetchDecisionDetails() async throws {
        let client = makeClient()
        mockHttp.stubbedResponseData = try JSONSerialization.data(withJSONObject: [
            "id": 5, "alert_id": 1, "origin": "", "type": "", "scope": "",
            "value": "", "expiration": "", "scenario": "", "simulated": false,
            "source": ["scope": "", "value": ""], "crowdsec_created_at": "",
            "alert": [
                "id": 1, "uuid": "", "scenario": "", "scenario_version": "",
                "scenario_hash": "", "message": "", "capacity": 0, "leakspeed": "",
                "simulated": false, "remediation": false, "events_count": 0,
                "machine_id": "", "source": ["scope": "", "value": ""],
                "meta": [], "events": [],
                "crowdsec_created_at": "", "start_at": "", "stop_at": ""
            ]
        ])
        let _: HttpResponse<DecisionItemResponse> = try await client.fetchDecisionDetails(decisionId: 5)
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/decisions/5")
    }

    func testCreateDecisionPost() async throws {
        let client = makeClient()
        let body = CreateDecisionRequest(ip: "10.0.0.1", duration: "24h", type: .ban, reason: "test")
        mockHttp.stubbedResponseData = Data("{}".utf8)
        let _: HttpResponse<EmptyResponse> = try await client.createDecision(body: body)
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/decisions")
    }

    func testDeleteDecision() async throws {
        let client = makeClient()
        mockHttp.stubbedResponseData = Data("{}".utf8)
        let _: HttpResponse<EmptyResponse> = try await client.deleteDecision(decisionId: 3)
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/decisions/3")
    }
}
