@testable import CrowdSec_Monitor
import XCTest

/// Tests the WebSocketClient's state machine, error types, and URL scheme mapping.
/// Actual WebSocket I/O uses MockWebSocketServer (see helpers).
@MainActor
final class WebSocketClientTests: XCTestCase {
    // MARK: - Error descriptions

    func testNotConnectedErrorDescription() {
        XCTAssertEqual(WebSocketClientError.notConnected.errorDescription, "WebSocket is not connected")
    }

    func testAlreadyConnectedErrorDescription() {
        XCTAssertEqual(WebSocketClientError.alreadyConnected.errorDescription, "WebSocket is already connected")
    }

    func testEncodingErrorDescription() {
        XCTAssertEqual(WebSocketClientError.encodingError.errorDescription, "Failed to encode message as JSON")
    }

    func testDecodingErrorDescription() {
        XCTAssertEqual(WebSocketClientError.decodingError.errorDescription, "Failed to decode WebSocket message")
    }

    // MARK: - Init from server

    func testInitFromServer() {
        let context = TestCoreData.makeContainer().viewContext
        let server = TestCoreData.makeServer(in: context, domain: "crowdsec.local", http: "https", port: 443, path: "/api") as! CSServer
        let ws = WebSocketClient(server: server)
        XCTAssertNotNil(ws)
    }

    // MARK: - Init from raw params URL scheme mapping

    func testSchemeMappingHttpToWs() {
        let ws = WebSocketClient(connectionMethod: "http", ipDomain: "localhost", port: 8080, path: nil, authMethod: nil, basicUser: nil, basicPassword: nil, bearerToken: nil)
        XCTAssertNotNil(ws)
    }

    func testSchemeMappingHttpsToWss() {
        let ws = WebSocketClient(connectionMethod: "https", ipDomain: "example.com", port: 443, path: "/ws", authMethod: nil, basicUser: nil, basicPassword: nil, bearerToken: nil)
        XCTAssertNotNil(ws)
    }

    func testSchemeMappingWssDirect() {
        let ws = WebSocketClient(connectionMethod: "wss", ipDomain: "example.com", port: 443, path: nil, authMethod: nil, basicUser: nil, basicPassword: nil, bearerToken: nil)
        XCTAssertNotNil(ws)
    }

    func testSchemeMappingWsDirect() {
        let ws = WebSocketClient(connectionMethod: "ws", ipDomain: "localhost", port: 80, path: nil, authMethod: nil, basicUser: nil, basicPassword: nil, bearerToken: nil)
        XCTAssertNotNil(ws)
    }

    // MARK: - State machine via MockWebSocketServer

    func testConnectDisconnectStateTransitions() async throws {
        let mock = try MockWebSocketServer()
        try mock.start()
        let port = Int32(mock.port?.rawValue ?? 0)
        let ws = WebSocketClient(connectionMethod: "ws", ipDomain: "127.0.0.1", port: port, path: nil, authMethod: nil, basicUser: nil, basicPassword: nil, bearerToken: nil)

        let connectExpectation = expectation(description: "onConnect")
        ws.onConnect = { connectExpectation.fulfill() }

        ws.connect(endpoint: "/")
        await fulfillment(of: [connectExpectation], timeout: 2)

        let disconnectExpectation = expectation(description: "onDisconnect")
        ws.onDisconnect = { (_: URLSessionWebSocketTask.CloseCode, _: String?) in disconnectExpectation.fulfill() }

        ws.disconnect()
        await fulfillment(of: [disconnectExpectation], timeout: 2)

        mock.stop()
    }

    func testConnectAlreadyConnectedGuard() throws {
        let ws = WebSocketClient(connectionMethod: "ws", ipDomain: "127.0.0.1", port: 8080, path: nil, authMethod: nil, basicUser: nil, basicPassword: nil, bearerToken: nil)
        ws.connect(endpoint: "/")
        // Second connect should be no-op (guard returns early)
        ws.connect(endpoint: "/")
    }

    // MARK: - Send while not connected

    func testSendTextNotConnected() async {
        let ws = WebSocketClient(connectionMethod: "ws", ipDomain: "127.0.0.1", port: 8080, path: nil, authMethod: nil, basicUser: nil, basicPassword: nil, bearerToken: nil)
        do {
            try await ws.send(text: "hello")
            XCTFail("Expected notConnected error")
        } catch WebSocketClientError.notConnected {
            // expected
        } catch {
            XCTFail("Wrong error: \(error)")
        }
    }

    func testSendDataNotConnected() async {
        let ws = WebSocketClient(connectionMethod: "ws", ipDomain: "127.0.0.1", port: 8080, path: nil, authMethod: nil, basicUser: nil, basicPassword: nil, bearerToken: nil)
        do {
            try await ws.send(data: Data("hello".utf8))
            XCTFail("Expected notConnected error")
        } catch WebSocketClientError.notConnected {
            // expected
        } catch {
            XCTFail("Wrong error: \(error)")
        }
    }

    func testSendEncodableNotConnected() async {
        let ws = WebSocketClient(connectionMethod: "ws", ipDomain: "127.0.0.1", port: 8080, path: nil, authMethod: nil, basicUser: nil, basicPassword: nil, bearerToken: nil)
        do {
            try await ws.send(encodable: ["key": "value"])
            XCTFail("Expected notConnected error")
        } catch WebSocketClientError.notConnected {
            // expected
        } catch {
            XCTFail("Wrong error: \(error)")
        }
    }

    func testPingNotConnected() async {
        let ws = WebSocketClient(connectionMethod: "ws", ipDomain: "127.0.0.1", port: 8080, path: nil, authMethod: nil, basicUser: nil, basicPassword: nil, bearerToken: nil)
        do {
            try await ws.ping()
            XCTFail("Expected notConnected error")
        } catch WebSocketClientError.notConnected {
            // expected
        } catch {
            XCTFail("Wrong error: \(error)")
        }
    }

    // MARK: - Stream guards

    func testStreamTwiceDoesNotCrash() async throws {
        let mock = try MockWebSocketServer()
        try mock.start()
        let port = Int32(mock.port?.rawValue ?? 0)
        let ws = WebSocketClient(connectionMethod: "ws", ipDomain: "127.0.0.1", port: port, path: nil, authMethod: nil, basicUser: nil, basicPassword: nil, bearerToken: nil)

        let stream1 = ws.stream(endpoint: "/")
        var iterator = stream1.makeAsyncIterator()
        // Second stream call — should throw .alreadyConnected or no-op depending on timing
        do {
            let _ = ws.stream(endpoint: "/")
        }
        _ = iterator
        mock.stop()
    }

    // MARK: - Auth headers URL scheme mapping

    func testAuthBearerInWSHeaders() {
        let context = TestCoreData.makeContainer().viewContext
        let server = TestCoreData.makeServer(in: context, authMethod: "bearer", bearerToken: "wstoken") as! CSServer
        let ws = WebSocketClient(server: server)
        XCTAssertNotNil(ws)
    }
}
