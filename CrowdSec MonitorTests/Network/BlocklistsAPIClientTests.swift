@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class BlocklistsAPIClientTests: XCTestCase {
    private var mockHttp: MockHttpClient!

    override func setUp() {
        super.setUp()
        mockHttp = MockHttpClient()
    }

    override func tearDown() {
        mockHttp = nil
        super.tearDown()
    }

    private func makeClient() -> BlocklistsAPIClient {
        BlocklistsAPIClient(mockHttp)
    }

    func testFetchBlocklistsWithPagination() async throws {
        let client = makeClient()
        let params = BlocklistsRequest(offset: 0, limit: 20)
        mockHttp.stubbedResponseData = try JSONSerialization.data(withJSONObject: [
            "items": [["id": "", "name": "", "count_ips": 0, "type": "api"]],
            "pagination": ["page": 1, "amount": 0, "total": 0]
        ])
        let _: HttpResponse<BlocklistsListResponse> = try await client.fetchBlocklists(requestParams: params)
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/blocklists")
        let query = mockHttp.capturedQueryParams ?? []
        XCTAssertTrue(query.contains { $0.name == "offset" && $0.value == "0" })
        XCTAssertTrue(query.contains { $0.name == "limit" && $0.value == "20" })
    }

    func testFetchBlocklistData() async throws {
        let client = makeClient()
        mockHttp.stubbedResponseData = Data("{\"data\":{\"id\":\"test-id\",\"name\":\"Test\",\"count_ips\":0,\"type\":\"api\",\"blocklistIps\":[]}}".utf8)
        let _: HttpResponse<BlocklistDataResponse> = try await client.fetchBlocklistData(blocklistId: "test-id")
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/blocklists/test-id")
    }

    func testFetchBlocklistIps() async throws {
        let client = makeClient()
        mockHttp.stubbedResponseData = Data("{\"data\":[],\"total\":0,\"limit\":0,\"offset\":0}".utf8)
        let _: HttpResponse<BlocklistIpsResponse> = try await client.fetchBlocklistIps(blocklistId: "test-id")
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/blocklists/test-id/ips")
    }

    func testAddBlocklist() async throws {
        let client = makeClient()
        let body = AddBlocklistRequestBody(name: "test", url: "http://example.com")
        mockHttp.stubbedResponseData = Data("{}".utf8)
        let _: HttpResponse<EmptyResponse> = try await client.addBlocklist(body: body)
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/blocklists")
    }

    func testToggleBlocklist() async throws {
        let client = makeClient()
        let params = ToggleBlocklistRequestParams(blocklistId: "bl-1")
        let body = ToggleBlocklistRequestBody(enabled: false)
        mockHttp.stubbedResponseData = Data("{}".utf8)
        let _: HttpResponse<EmptyResponse> = try await client.toggleBlocklist(params: params, body: body)
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/blocklists/bl-1/enabled")
    }

    func testDeleteBlocklist() async throws {
        let client = makeClient()
        let params = DeleteBlocklistRequestParams(blocklistId: "bl-2")
        mockHttp.stubbedResponseData = Data("{}".utf8)
        let _: HttpResponse<EmptyResponse> = try await client.deleteBlocklist(params: params)
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/blocklists/bl-2")
    }

    func testCheckIps() async throws {
        let client = makeClient()
        let body = BlocklistsCheckIPsRequest(ips: ["10.0.0.1"])
        mockHttp.stubbedResponseData = Data("{\"results\":[]}".utf8)
        let _: HttpResponse<BlocklistsCheckIPsResponse> = try await client.checkIps(body)
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/blocklists/check")
    }

    func testCheckDomain() async throws {
        let client = makeClient()
        let body = BlocklistsCheckDomainRequest(domain: "example.com")
        mockHttp.stubbedResponseData = Data("{\"domain\":\"example.com\",\"ips\":[]}".utf8)
        let _: HttpResponse<BlocklistsCheckDomainResponse> = try await client.checkDomain(body)
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/blocklists/check-domain")
    }

    func testRefreshAllBlocklists() async throws {
        let client = makeClient()
        mockHttp.stubbedResponseData = Data("{\"message\":\"ok\"}".utf8)
        let _: HttpResponse<RefreshBlocklistsResponse> = try await client.refreshAllBlocklists()
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/lists/refresh")
    }

    func testRefreshSingleBlocklist() async throws {
        let client = makeClient()
        mockHttp.stubbedResponseData = Data("{\"message\":\"ok\"}".utf8)
        let _: HttpResponse<RefreshBlocklistsResponse> = try await client.refreshBlocklist(blocklistId: "test")
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/lists/blocklists/test/refresh")
    }
}
