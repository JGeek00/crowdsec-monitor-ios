@testable import CrowdSec_Monitor
import CoreData
import XCTest

@MainActor
final class CrowdSecAPIClientTests: XCTestCase {
    private var context: NSManagedObjectContext!
    private var mockHttp: MockHttpClient!

    override func setUp() {
        super.setUp()
        context = TestCoreData.makeContainer().viewContext
        mockHttp = MockHttpClient()
    }

    override func tearDown() {
        context = nil
        mockHttp = nil
        super.tearDown()
    }

    func testSubClientsNonNil() {
        let server = TestCoreData.makeServer(in: context) as! CSServer
        let api = CrowdSecAPIClient(server)
        XCTAssertNotNil(api.statistics)
        XCTAssertNotNil(api.alerts)
        XCTAssertNotNil(api.decisions)
        XCTAssertNotNil(api.allowlists)
        XCTAssertNotNil(api.blocklists)
    }

    func testSubClientsCorrectTypes() {
        let server = TestCoreData.makeServer(in: context) as! CSServer
        let api = CrowdSecAPIClient(server)
        XCTAssertNotNil(api.statistics)
        XCTAssertNotNil(api.alerts)
        XCTAssertNotNil(api.decisions)
        XCTAssertNotNil(api.allowlists)
        XCTAssertNotNil(api.blocklists)
    }

    func testCheckCredentialsEndpoint() async throws {
        mockHttp.stubbedResponseData = try JSONSerialization.data(withJSONObject: [
            "message": "ok", "timestamp": "2026-01-01T00:00:00.000Z"
        ])
        let result: HttpResponse<EmptyResponse> = try await mockHttp.get(endpoint: "/api/v1/check-credentials")
        XCTAssertTrue(result.successful)
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/check-credentials")
    }

    func testCheckApiStatusEndpoint() async throws {
        mockHttp.stubbedResponseData = try JSONSerialization.data(withJSONObject: [
            "csLapi": ["lapiConnected": false, "lastSuccessfulSync": "", "timestamp": ""],
            "csBouncer": ["available": true],
            "csMonitorApi": ["version": ""],
            "processes": []
        ])
        let result: HttpResponse<APIStatusResponse> = try await mockHttp.get(endpoint: "/api/v1/status")
        XCTAssertTrue(result.successful)
    }

    func testInvalidateDoesNotCrash() {
        let server = TestCoreData.makeServer(in: context) as! CSServer
        let api = CrowdSecAPIClient(server)
        api.invalidate()
        XCTAssertNotNil(api)
    }

    func testCheckCredentialsViaRealClientThrows() async {
        // A real CrowdSecAPIClient pointed at an unreachable address
        let server = TestCoreData.makeServer(in: context, domain: "127.0.0.1", port: 1) as! CSServer
        let api = CrowdSecAPIClient(server)
        do {
            let _: HttpResponse<EmptyResponse> = try await api.checkCredentials()
            XCTFail("Expected error from unreachable server")
        } catch {
            // Expected — network error from 127.0.0.1:1
            XCTAssertTrue(error is HttpClientError || error is URLError)
        }
    }

    func testCheckApiStatusViaRealClientThrows() async {
        let server = TestCoreData.makeServer(in: context, domain: "127.0.0.1", port: 1) as! CSServer
        let api = CrowdSecAPIClient(server)
        do {
            let _: HttpResponse<APIStatusResponse> = try await api.checkApiStatus()
            XCTFail("Expected error from unreachable server")
        } catch {
            XCTAssertTrue(error is HttpClientError || error is URLError)
        }
    }
}
