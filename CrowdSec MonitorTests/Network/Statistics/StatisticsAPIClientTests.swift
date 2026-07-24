@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class StatisticsAPIClientTests: XCTestCase {
    private var mockHttp: MockHttpClient!

    override func setUp() {
        super.setUp()
        mockHttp = MockHttpClient()
    }

    override func tearDown() {
        mockHttp = nil
        super.tearDown()
    }

    private func makeClient() -> StatisticsAPIClient {
        StatisticsAPIClient(mockHttp)
    }

    func testFetchStatistics() async throws {
        let client = makeClient()
        mockHttp.stubbedResponseData = try JSONSerialization.data(withJSONObject: [
            "alertsLast24Hours": 10, "activeDecisions": 5,
            "activityHistory": [["date": "2026-01-01", "amountAlerts": 1, "amountDecisions": 1]],
            "topCountries": [["countryCode": "US", "amount": 1]],
            "topScenarios": [["scenario": "test", "amount": 1]],
            "topIpOwners": [["ipOwner": "test", "amount": 1]],
            "topTargets": [["target": "test", "amount": 1]]
        ])
        let result: HttpResponse<StatisticsResponse> = try await client.fetchStatistics()
        XCTAssertTrue(result.successful)
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/statistics")
    }

    func testFetchStatisticsWithParams() async throws {
        let client = makeClient()
        mockHttp.stubbedResponseData = try JSONSerialization.data(withJSONObject: [
            "alertsLast24Hours": 10, "activeDecisions": 5,
            "activityHistory": [["date": "2026-01-01", "amountAlerts": 1, "amountDecisions": 1]],
            "topCountries": [["countryCode": "US", "amount": 1]],
            "topScenarios": [["scenario": "test", "amount": 1]],
            "topIpOwners": [["ipOwner": "test", "amount": 1]],
            "topTargets": [["target": "test", "amount": 1]]
        ])
        let _: HttpResponse<StatisticsResponse> = try await client.fetchStatistics(amount: 10, since: Date(timeIntervalSince1970: 0))
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/statistics")
        let query = mockHttp.capturedQueryParams ?? []
        XCTAssertTrue(query.contains { $0.name == "amount" && $0.value == "10" })
    }

    func testSubClientsNonNil() {
        let client = makeClient()
        XCTAssertNotNil(client.countries)
        XCTAssertNotNil(client.ipOwners)
        XCTAssertNotNil(client.scenarios)
        XCTAssertNotNil(client.targets)
    }
}
