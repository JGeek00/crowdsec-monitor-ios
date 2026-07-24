import Foundation
import Network

/// An in-process WebSocket server built on `Network.framework` `NWListener`.
/// Binds to `127.0.0.1:<ephemeral>` so the test can construct a `CSServer`
/// pointing at the returned `port` and drive `WebSocketClient` lifecycle tests
/// without any real network.
final class MockWebSocketServer: @unchecked Sendable {
    private var listener: NWListener?
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "com.jgeek00.CrowdSec-Monitor.tests.mock-ws")

    /// The ephemeral port the server bound to. Read after `start()` completes.
    private(set) var port: NWEndpoint.Port?

    // MARK: - Lifecycle

    /// Start listening on an ephemeral port. Must be called before any client connects.
    func start() throws {
        let params = NWParameters(tls: nil)
        let wsOptions = NWProtocolWebSocket.Options()
        wsOptions.autoReplyPing = true
        params.defaultProtocolStack.applicationProtocols.insert(wsOptions, at: 0)

        listener = try NWListener(using: params, on: .any)
        port = listener?.port

        listener?.newConnectionHandler = { [weak self] conn in
            guard let self else { return }
            self.connection = conn
            conn.start(queue: self.queue)
        }

        listener?.start(queue: queue)
    }

    /// Send a text frame to the connected client.
    func send(text: String) {
        let metadata = NWProtocolWebSocket.Metadata(opcode: .text)
        let content = Data(text.utf8)
        let context = NWConnection.ContentContext(identifier: "mock-frame", metadata: [metadata])
        connection?.send(content: content, contentContext: context, isComplete: true, completion: .contentProcessed { _ in })
    }

    /// Send a binary frame to the connected client.
    func send(data: Data) {
        let metadata = NWProtocolWebSocket.Metadata(opcode: .binary)
        let context = NWConnection.ContentContext(identifier: "mock-frame", metadata: [metadata])
        connection?.send(content: data, contentContext: context, isComplete: true, completion: .contentProcessed { _ in })
    }

    /// Close the connection with the given close code.
    func close(code: URLSessionWebSocketTask.CloseCode = .normalClosure) {
        let metadata = NWProtocolWebSocket.Metadata(opcode: .close)
        let reason: Data? = nil
        let context = NWConnection.ContentContext(identifier: "close-frame", metadata: [metadata])
        connection?.send(content: reason, contentContext: context, isComplete: true, completion: .contentProcessed { _ in })
        connection?.cancel()
    }

    /// Tear down the listener.
    func stop() {
        connection?.cancel()
        listener?.cancel()
        connection = nil
        listener = nil
        port = nil
    }
}
