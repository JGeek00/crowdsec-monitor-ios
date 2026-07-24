@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class AllowlistsAPIClientTests: XCTestCase {
    private var mockHttp: MockHttpClient!

    override func setUp() {
        super.setUp()
        mockHttp = MockHttpClient()
    }

    override func tearDown() {
        mockHttp = nil
        super.tearDown()
    }

    private func makeClient() -> AllowlistsAPIClient {
        AllowlistsAPIClient(mockHttp)
    }

    func testFetchAllowlists() async throws {
        let client = makeClient()
        mockHttp.stubbedResponseData = try JSONSerialization.data(withJSONObject: [
            "data": [], "length": 0
        ])
        let result: HttpResponse<AllowlistsListResponse> = try await client.fetchAllowlists()
        XCTAssertTrue(result.successful)
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/allowlists")
    }

    func testCheckIps() async throws {
        let client = makeClient()
        let body = AllowlistsCheckIPsRequest(ips: ["10.0.0.1"])
        mockHttp.stubbedResponseData = Data("{\"results\":[]}".utf8)
        let _: HttpResponse<AllowlistsCheckIPsResponse> = try await client.checkIps(body)
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/allowlists/check")
    }
}
