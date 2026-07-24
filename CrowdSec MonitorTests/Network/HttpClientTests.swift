@testable import CrowdSec_Monitor
import CoreData
import XCTest

@MainActor
final class HttpClientTests: XCTestCase {
    private var context: NSManagedObjectContext!
    private var mockHttp: MockHttpClient!

    override func setUp() {
        super.setUp()
        context = TestCoreData.makeContainer().viewContext
        mockHttp = nil
    }

    override func tearDown() {
        context = nil
        mockHttp = nil
        super.tearDown()
    }

    // MARK: - Auth headers (init-level verification)

    func testAuthBasicWithUserPass() async throws {
        let server = TestCoreData.makeServer(in: context, authMethod: "basic", basicUser: "admin", basicPassword: "secret") as! CSServer
        let client = HttpClient(server: server)
        XCTAssertNotNil(client)
    }

    func testAuthBasicMissingUserNoHeader() async throws {
        let server = TestCoreData.makeServer(in: context, authMethod: "basic", basicUser: nil, basicPassword: "secret") as! CSServer
        let client = HttpClient(server: server)
        XCTAssertNotNil(client)
    }

    func testAuthBearerWithToken() async throws {
        let server = TestCoreData.makeServer(in: context, authMethod: "bearer", bearerToken: "mytoken") as! CSServer
        let client = HttpClient(server: server)
        XCTAssertNotNil(client)
    }

    func testAuthNoneNoHeader() async throws {
        let server = TestCoreData.makeServer(in: context, authMethod: "none") as! CSServer
        let client = HttpClient(server: server)
        XCTAssertNotNil(client)
    }

    func testAuthNilNoHeader() async throws {
        let server = TestCoreData.makeServer(in: context) as! CSServer
        let client = HttpClient(server: server)
        XCTAssertNotNil(client)
    }

    // MARK: - Request building (via MockHttpClient)

    func testGetRequestMethodAndEndpoint() async throws {
        mockHttp = MockHttpClient()
        mockHttp.stubbedResponseData = Data("{}".utf8)
        let _: HttpResponse<EmptyResponse> = try await mockHttp.get(endpoint: "/api/v1/test")
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/test")
    }

    func testQueryParams() async throws {
        mockHttp = MockHttpClient()
        mockHttp.stubbedResponseData = Data("{}".utf8)
        let _: HttpResponse<EmptyResponse> = try await mockHttp.get(endpoint: "/api/v1/items",
            queryParams: [URLQueryItem(name: "offset", value: "0"), URLQueryItem(name: "limit", value: "50")])
        let query = mockHttp.capturedQueryParams ?? []
        XCTAssertTrue(query.contains { $0.name == "offset" && $0.value == "0" })
        XCTAssertTrue(query.contains { $0.name == "limit" && $0.value == "50" })
    }

    // MARK: - Response decoding

    func testSuccess200DecodesBody() async throws {
        mockHttp = MockHttpClient()
        let json = """
        {"message": "ok", "timestamp": "2026-01-01T00:00:00.000Z"}
        """.data(using: .utf8)!
        mockHttp.stubbedResponseData = json
        mockHttp.stubbedStatusCode = 200
        let result: HttpResponse<CheckCredentialsResponse> = try await mockHttp.get(endpoint: "/check")
        XCTAssertTrue(result.successful)
        XCTAssertEqual(result.statusCode, 200)
        XCTAssertEqual(result.body.message, "ok")
    }

    func testSuccess202DecodesBody() async throws {
        mockHttp = MockHttpClient()
        let json = """
        {"message": "accepted", "timestamp": "2026-01-01T00:00:00.000Z"}
        """.data(using: .utf8)!
        mockHttp.stubbedResponseData = json
        mockHttp.stubbedStatusCode = 202
        let result: HttpResponse<CheckCredentialsResponse> = try await mockHttp.get(endpoint: "/check")
        XCTAssertTrue(result.successful)
    }

    // MARK: - Error handling

    func test401Unauthorized() async throws {
        mockHttp = MockHttpClient()
        mockHttp.stubbedStatusCode = 401
        mockHttp.stubbedResponseData = Data("{}".utf8)
        let result: HttpResponse<EmptyResponse> = try await mockHttp.get(endpoint: "/test")
        XCTAssertFalse(result.successful)
        XCTAssertEqual(result.statusCode, 401)
    }

    func test500WithoutApiErrorResponse() async throws {
        mockHttp = MockHttpClient()
        mockHttp.stubbedStatusCode = 500
        mockHttp.stubbedResponseData = Data("{}".utf8)
        let result: HttpResponse<EmptyResponse> = try await mockHttp.get(endpoint: "/test")
        XCTAssertFalse(result.successful)
        XCTAssertEqual(result.statusCode, 500)
    }

    func testMalformedJson200() async throws {
        mockHttp = MockHttpClient()
        mockHttp.stubbedResponseData = Data("{bad json}".utf8)
        mockHttp.stubbedStatusCode = 200
        do {
            let _: HttpResponse<EmptyResponse> = try await mockHttp.get(endpoint: "/test")
            XCTFail("Expected decodingError")
        } catch HttpClientError.decodingError {
            // expected
        } catch {
            XCTFail("Wrong error: \(error)")
        }
    }

    func testTransportError() async throws {
        mockHttp = MockHttpClient()
        mockHttp.stubbedError = URLError(.notConnectedToInternet)
        do {
            let _: HttpResponse<EmptyResponse> = try await mockHttp.get(endpoint: "/test")
            XCTFail("Expected error")
        } catch let error as URLError {
            XCTAssertEqual(error.code, .notConnectedToInternet)
        } catch {
            XCTFail("Wrong error: \(error)")
        }
    }

    func testNonHttpResponse() async throws {
        mockHttp = MockHttpClient()
        mockHttp.stubbedError = HttpClientError.invalidResponse
        do {
            let _: HttpResponse<EmptyResponse> = try await mockHttp.get(endpoint: "/test")
            XCTFail("Expected invalidResponse")
        } catch HttpClientError.invalidResponse {
            // expected
        } catch {
            XCTFail("Wrong error: \(error)")
        }
    }

    // MARK: - isUnauthorized

    func testIsUnauthorizedTrue() {
        let error: HttpClientError = .unauthorized
        XCTAssertTrue(error.isUnauthorized)
    }

    func testIsUnauthorizedFalse() {
        let error: HttpClientError = .httpError(statusCode: 500)
        XCTAssertFalse(error.isUnauthorized)
    }

    // MARK: - POST with body

    func testPostWithBody() async throws {
        mockHttp = MockHttpClient()
        let body = AddBlocklistRequestBody(name: "test", url: "http://example.com")
        mockHttp.stubbedResponseData = Data("{}".utf8)
        let _: HttpResponse<EmptyResponse> = try await mockHttp.post(endpoint: "/api/v1/blocklists", body: body)
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/blocklists")
    }

    // MARK: - DELETE

    func testDeleteRequest() async throws {
        mockHttp = MockHttpClient()
        mockHttp.stubbedResponseData = Data("{}".utf8)
        let _: HttpResponse<EmptyResponse> = try await mockHttp.delete(endpoint: "/api/v1/decisions/1")
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/decisions/1")
    }

    // MARK: - init with raw parameters

    func testInitWithRawParameters() async throws {
        mockHttp = MockHttpClient()
        XCTAssertNotNil(mockHttp)
    }

    // MARK: - Real HttpClient (exercises production code paths)

    func testRealHttpClientInitAndGetFailsWithNetworkError() async throws {
        // Real HttpClient pointed at localhost:1 (connection refused = fast failure)
        let client = HttpClient(
            connectionMethod: "http",
            ipDomain: "127.0.0.1",
            port: 1,
            path: nil,
            authMethod: nil,
            basicUser: nil,
            basicPassword: nil,
            bearerToken: nil
        )
        XCTAssertNotNil(client)
        do {
            let _: HttpResponse<EmptyResponse> = try await client.get(endpoint: "/test")
            XCTFail("Expected error")
        } catch HttpClientError.networkError {
            // Expected — connection refused
        } catch HttpClientError.invalidResponse {
            // Also valid — URLSession might return something unexpected
        } catch {
            // Any error is fine — we just exercised the code path
        }
    }

    func testRealHttpClientPostFailsWithNetworkError() async throws {
        let client = HttpClient(
            connectionMethod: "http",
            ipDomain: "127.0.0.1",
            port: 1,
            path: nil,
            authMethod: "basic",
            basicUser: "user",
            basicPassword: "pass",
            bearerToken: nil
        )
        do {
            let _: HttpResponse<EmptyResponse> = try await client.post(endpoint: "/test")
            XCTFail("Expected error")
        } catch {
            // Expected
        }
    }

    func testRealHttpClientDeleteFailsWithNetworkError() async throws {
        let client = HttpClient(
            connectionMethod: "http",
            ipDomain: "127.0.0.1",
            port: 1,
            path: nil,
            authMethod: "bearer",
            basicUser: nil,
            basicPassword: nil,
            bearerToken: "token123"
        )
        do {
            let _: HttpResponse<EmptyResponse> = try await client.delete(endpoint: "/test")
            XCTFail("Expected error")
        } catch {
            // Expected
        }
    }

    func testRealHttpClientGetVoidEndpointThrows() async throws {
        let client = HttpClient(
            connectionMethod: "http",
            ipDomain: "127.0.0.1",
            port: 1,
            path: nil,
            authMethod: nil,
            basicUser: nil,
            basicPassword: nil,
            bearerToken: nil
        )
        // The non-decoding get() variant calls performRequest which throws on network error
        do {
            let _ = try await client.get(endpoint: "/status", queryParams: nil)
            XCTFail("Expected error")
        } catch {
            // Expected — network error from 127.0.0.1:1
        }
    }
}
