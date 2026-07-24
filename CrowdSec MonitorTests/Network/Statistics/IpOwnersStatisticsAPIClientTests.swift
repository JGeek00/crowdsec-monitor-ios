@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class IpOwnersStatisticsAPIClientTests: XCTestCase {
    private var mockHttp: MockHttpClient!

    override func setUp() {
        super.setUp()
        mockHttp = MockHttpClient()
    }

    override func tearDown() {
        mockHttp = nil
        super.tearDown()
    }

    func testEndpoint() async throws {
        let client = IpOwnersStatisticsAPIClient(mockHttp)
        mockHttp.stubbedResponseData = Data("[]".utf8)
        let _: HttpResponse<[TopIPOwner]> = try await client.fetchIpOwnersStatistics()
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/statistics/ip-owners")
    }
}
