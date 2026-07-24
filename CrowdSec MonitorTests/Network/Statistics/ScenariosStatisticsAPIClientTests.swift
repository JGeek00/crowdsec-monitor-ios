@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class ScenariosStatisticsAPIClientTests: XCTestCase {
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
        let client = ScenariosStatisticsAPIClient(mockHttp)
        mockHttp.stubbedResponseData = Data("[]".utf8)
        let _: HttpResponse<[TopScenario]> = try await client.fetchScenariosStatistics()
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/statistics/scenarios")
    }
}
