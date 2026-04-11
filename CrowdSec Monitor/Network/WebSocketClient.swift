import Foundation

// MARK: - WebSocket Message

enum WebSocketMessage {
    case text(String)
    case data(Data)
}

// MARK: - WebSocket Client State

enum WebSocketState {
    case disconnected
    case connecting
    case connected
}

// MARK: - WebSocket Client

class WebSocketClient: NSObject {
    private let baseURL: URL
    private var session: URLSession
    private var authHeader: [String: String]?
    private var webSocketTask: URLSessionWebSocketTask?

    private(set) var state: WebSocketState = .disconnected

    var onMessage: ((WebSocketMessage) -> Void)?
    var onConnect: (() -> Void)?
    var onDisconnect: ((URLSessionWebSocketTask.CloseCode, String?) -> Void)?
    var onError: ((Error) -> Void)?

    // MARK: - Init from CSServer

    init(server: CSServer) {
        let urlString = buildUrl(server: server)
            .replacingOccurrences(of: "^http://", with: "ws://", options: .regularExpression)
            .replacingOccurrences(of: "^https://", with: "wss://", options: .regularExpression)

        guard let url = URL(string: urlString) else {
            fatalError("Invalid server configuration URL: \(urlString)")
        }

        self.baseURL = url
        self.session = URLSession.shared

        super.init()

        self.session = Self.createSession(withDelegate: self)
        self.configureAuth(
            authMethod: server.authMethod,
            basicUser: server.basicUser,
            basicPassword: server.basicPassword,
            bearerToken: server.bearerToken
        )
    }

    // MARK: - Init from raw parameters

    init(
        connectionMethod: String,
        ipDomain: String,
        port: Int32?,
        path: String?,
        authMethod: String?,
        basicUser: String?,
        basicPassword: String?,
        bearerToken: String?
    ) {
        // Map http(s) → ws(s); accept ws/wss directly
        let scheme: String
        switch connectionMethod.lowercased() {
        case "https", "wss": scheme = "wss"
        default:             scheme = "ws"
        }

        var urlString = "\(scheme)://\(ipDomain)"

        if let port = port, port > 0 {
            urlString += ":\(port)"
        }

        if let path = path, !path.isEmpty {
            urlString += path.hasPrefix("/") ? path : "/\(path)"
        }

        guard let url = URL(string: urlString) else {
            fatalError("Invalid WebSocket URL: \(urlString)")
        }

        self.baseURL = url
        self.session = URLSession.shared

        super.init()

        self.session = Self.createSession(withDelegate: self)
        self.configureAuth(
            authMethod: authMethod,
            basicUser: basicUser,
            basicPassword: basicPassword,
            bearerToken: bearerToken
        )
    }

    // MARK: - Configuration

    private static func createSession(withDelegate delegate: URLSessionDelegate) -> URLSession {
        let config = URLSessionConfiguration.default
        // No timeouts — WebSocket connections are long-lived by design.
        // timeoutIntervalForRequest (default 60s) and timeoutIntervalForResource
        // would kill the connection during idle periods.
        config.timeoutIntervalForRequest = .infinity
        config.timeoutIntervalForResource = .infinity
        return URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
    }

    private func configureAuth(
        authMethod: String?,
        basicUser: String?,
        basicPassword: String?,
        bearerToken: String?
    ) {
        guard let authMethod = authMethod else {
            self.authHeader = nil
            return
        }

        switch authMethod {
        case "basic":
            if let user = basicUser, let password = basicPassword {
                let credentials = "\(user):\(password)"
                if let data = credentials.data(using: .utf8) {
                    let encoded = data.base64EncodedString()
                    self.authHeader = ["Authorization": "Basic \(encoded)"]
                }
            }
        case "bearer":
            if let token = bearerToken {
                self.authHeader = ["Authorization": "Bearer \(token)"]
            }
        default:
            self.authHeader = nil
        }
    }

    // MARK: - Connection

    /// Connect to the given WebSocket endpoint path (e.g. "/api/v1/events").
    func connect(endpoint: String) {
        guard state == .disconnected else { return }

        state = .connecting

        let url = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        authHeader?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        webSocketTask = session.webSocketTask(with: request)
        webSocketTask?.resume()

        state = .connected
        onConnect?()
        receiveNextMessage()
    }

    /// Opens a WebSocket connection to `endpoint` and returns an `AsyncThrowingStream`
    /// that emits decoded `T` values as they arrive. The stream ends when the connection
    /// closes or an unrecoverable error occurs.
    func stream<T: Decodable>(endpoint: String, as type: T.Type = T.self) -> AsyncThrowingStream<T, Error> {
        AsyncThrowingStream { continuation in
            guard state == .disconnected else {
                continuation.finish(throwing: WebSocketClientError.alreadyConnected)
                return
            }

            state = .connecting

            let url = baseURL.appendingPathComponent(endpoint)
            var request = URLRequest(url: url)
            authHeader?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

            let task = session.webSocketTask(with: request)
            self.webSocketTask = task
            task.resume()

            state = .connected
            onConnect?()

            // Send a ping every 30 s to keep the connection alive and detect
            // silent drops before the OS closes the socket.
            let pingTask = Task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(30))
                    guard !Task.isCancelled else { break }
                    task.sendPing { _ in }
                }
            }

            continuation.onTermination = { _ in
                pingTask.cancel()
                task.cancel(with: .normalClosure, reason: nil)
            }

            func receive() {
                task.receive { [weak self] result in
                    guard let self else {
                        continuation.finish()
                        return
                    }
                    switch result {
                    case .success(let message):
                        do {
                            let data: Data
                            switch message {
                            case .string(let text):
                                guard let encoded = text.data(using: .utf8) else {
                                    throw WebSocketClientError.decodingError
                                }
                                data = encoded
                            case .data(let bytes):
                                data = bytes
                            @unknown default:
                                receive()
                                return
                            }
                            let decoded = try JSONDecoder().decode(T.self, from: data)
                            continuation.yield(decoded)
                            receive()
                        } catch {
                            continuation.finish(throwing: error)
                            self.state = .disconnected
                        }
                    case .failure(let error):
                        let nsError = error as NSError
                        if nsError.code == NSURLErrorCancelled {
                            self.state = .disconnected
                            continuation.finish()
                        } else {
                            self.state = .disconnected
                            continuation.finish(throwing: error)
                        }
                    }
                }
            }

            receive()
        }
    }

    /// Disconnect gracefully.
    func disconnect(closeCode: URLSessionWebSocketTask.CloseCode = .normalClosure, reason: String? = nil) {
        guard state != .disconnected else { return }

        let reasonData = reason?.data(using: .utf8)
        webSocketTask?.cancel(with: closeCode, reason: reasonData)
        webSocketTask = nil
        state = .disconnected
    }

    // MARK: - Sending

    /// Send a text message.
    func send(text: String) async throws {
        guard state == .connected, let task = webSocketTask else {
            throw WebSocketClientError.notConnected
        }
        try await task.send(.string(text))
    }

    /// Send a binary message.
    func send(data: Data) async throws {
        guard state == .connected, let task = webSocketTask else {
            throw WebSocketClientError.notConnected
        }
        try await task.send(.data(data))
    }

    /// Send an `Encodable` value serialised as JSON text.
    func send<T: Encodable>(encodable value: T) async throws {
        let data = try JSONEncoder().encode(value)
        guard let text = String(data: data, encoding: .utf8) else {
            throw WebSocketClientError.encodingError
        }
        try await send(text: text)
    }

    // MARK: - Ping / Pong

    /// Send a ping and await the pong. Throws on failure.
    func ping() async throws {
        guard state == .connected, let task = webSocketTask else {
            throw WebSocketClientError.notConnected
        }
        return try await withCheckedThrowingContinuation { continuation in
            task.sendPing { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    // MARK: - Private receive loop

    private func receiveNextMessage() {
        guard state == .connected, let task = webSocketTask else { return }

        task.receive { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self.onMessage?(.text(text))
                case .data(let data):
                    self.onMessage?(.data(data))
                @unknown default:
                    break
                }
                // Keep listening
                self.receiveNextMessage()

            case .failure(let error):
                // A cancellation error means we intentionally disconnected
                let nsError = error as NSError
                if nsError.code == NSURLErrorCancelled {
                    self.state = .disconnected
                    self.onDisconnect?(.normalClosure, nil)
                } else {
                    self.onError?(error)
                    self.state = .disconnected
                    self.onDisconnect?(.abnormalClosure, error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - URLSessionDelegate (SSL pinning bypass, same as HttpClient)

extension WebSocketClient: URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
                return
            }
        }
        completionHandler(.performDefaultHandling, nil)
    }
}

// MARK: - Errors

enum WebSocketClientError: LocalizedError {
    case notConnected
    case alreadyConnected
    case encodingError
    case decodingError

    var errorDescription: String? {
        switch self {
        case .notConnected:
            return "WebSocket is not connected"
        case .alreadyConnected:
            return "WebSocket is already connected"
        case .encodingError:
            return "Failed to encode message as JSON"
        case .decodingError:
            return "Failed to decode WebSocket message"
        }
    }
}
