@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class CountriesStatisticsAPIClientTests: XCTestCase {
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
        let client = CountriesStatisticsAPIClient(mockHttp)
        mockHttp.stubbedResponseData = Data("[]".utf8)
        let _: HttpResponse<[TopCountry]> = try await client.fetchCountriesStatistics()
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/statistics/countries")
    }
}
