import Foundation

// MARK: - HTTP Response Structure

struct HttpResponse<T: Decodable>: Decodable {
    let successful: Bool
    let statusCode: Int
    let body: T
}

// MARK: - Empty Response (for DELETE, etc.)

struct EmptyResponse: Decodable {
    init() {}
    
    init(from decoder: Decoder) throws {
        // No-op - can decode from any data
    }
}

class HttpClient: NSObject {
    private let baseURL: URL
    private var session: URLSession
    private var authHeader: [String: String]?
    
    init(server: CSServer) {
        var urlString = "\(server.http ?? "https")://\(server.domain ?? "")"
        
        if server.port > 0 {
            urlString += ":\(server.port)"
        }
        
        if let path = server.path, !path.isEmpty {
            if path.hasPrefix("/") {
                urlString += path
            } else {
                urlString += "/\(path)"
            }
        }
        
        guard let url = URL(string: urlString) else {
            fatalError("Invalid server configuration URL: \(urlString)")
        }
        
        self.baseURL = url
        self.session = URLSession.shared
        
        super.init()
        
        self.session = Self.createSession(withDelegate: self)
        self.configureAuth(authMethod: server.authMethod, basicUser: server.basicUser, basicPassword: server.basicPassword, bearerToken: server.bearerToken)
    }
    
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
        var urlString = "\(connectionMethod)://\(ipDomain)"
        
        if let port = port, port > 0 {
            urlString += ":\(port)"
        }
        
        if let path = path, !path.isEmpty {
            if path.hasPrefix("/") {
                urlString += path
            } else {
                urlString += "/\(path)"
            }
        }
        
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL: \(urlString)")
        }
        
        self.baseURL = url
        self.session = URLSession.shared
        
        super.init()
        
        self.session = Self.createSession(withDelegate: self)
        self.configureAuth(authMethod: authMethod, basicUser: basicUser, basicPassword: basicPassword, bearerToken: bearerToken)
    }
    
    // MARK: - Configuration
    
    private static func createSession(withDelegate delegate: URLSessionDelegate) -> URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        return URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
    }
    
    private func configureAuth(authMethod: String?, basicUser: String?, basicPassword: String?, bearerToken: String?) {
        guard let authMethod = authMethod else {
            self.authHeader = nil
            return
        }
        
        switch authMethod {
        case "basic":
            if let user = basicUser, let password = basicPassword {
                let credentials = "\(user):\(password)"
                if let credentialsData = credentials.data(using: .utf8) {
                    let base64Credentials = credentialsData.base64EncodedString()
                    self.authHeader = ["Authorization": "Basic \(base64Credentials)"]
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
    
    // MARK: - HTTP methods (internal - used by API clients)
    
    func get<T: Decodable>(endpoint: String, queryParams: [URLQueryItem]? = nil) async throws -> HttpResponse<T> {
        return try await request(method: "GET", endpoint: endpoint, queryParams: queryParams)
    }
    
    func post<T: Encodable, R: Decodable>(endpoint: String, body: T) async throws -> HttpResponse<R> {
        return try await request(method: "POST", endpoint: endpoint, body: body, queryParams: nil)
    }
    
    func put<T: Encodable, R: Decodable>(endpoint: String, body: T) async throws -> HttpResponse<R> {
        return try await request(method: "PUT", endpoint: endpoint, body: body, queryParams: nil)
    }
    
    func delete<T: Decodable>(endpoint: String, queryParams: [URLQueryItem]? = nil) async throws -> HttpResponse<T> {
        return try await request(method: "DELETE", endpoint: endpoint, queryParams: queryParams)
    }
    
    // MARK: - Private helpers
    
    private func request<T: Encodable, R: Decodable>(
        method: String,
        endpoint: String,
        body: T? = nil as String?,
        queryParams: [URLQueryItem]? = nil
    ) async throws -> HttpResponse<R> {
        var request = try buildRequest(method: method, endpoint: endpoint, body: body, queryParams: queryParams)
        let (data, statusCode) = try await performRequest(&request)
        let decodedBody: R = try decode(data)
        
        return HttpResponse(
            successful: (200...299).contains(statusCode),
            statusCode: statusCode,
            body: decodedBody
        )
    }
    
    private func buildRequest<T: Encodable>(
        method: String,
        endpoint: String,
        body: T?,
        queryParams: [URLQueryItem]? = nil
    ) throws -> URLRequest {
        var url = baseURL.appendingPathComponent(endpoint)
        
        // Add query parameters if present
        if let queryParams = queryParams, !queryParams.isEmpty {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = queryParams
            
            if let urlWithQuery = components?.url {
                url = urlWithQuery
            }
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authentication headers
        authHeader?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        // Add body if present
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        return request
    }
    
    private func performRequest(_ request: inout URLRequest) async throws -> (Data, Int) {
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw HttpClientError.networkError(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HttpClientError.invalidResponse
        }
        
        let statusCode = httpResponse.statusCode
        
        if statusCode == 401 {
            throw HttpClientError.unauthorized
        }
        
        guard (200...299).contains(statusCode) else {
            throw HttpClientError.httpError(statusCode: statusCode)
        }
        
        return (data, statusCode)
    }
    
    private func decode<T: Decodable>(_ data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // Try ISO8601 with milliseconds format: "2026-02-14T20:29:54.000Z"
            let iso8601Formatter = ISO8601DateFormatter()
            iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = iso8601Formatter.date(from: dateString) {
                return date
            }
            
            // Try custom timestamp format: "2026-02-14 21:29:50 +0100 +0100"
            let customFormatter = DateFormatter()
            customFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z Z"
            customFormatter.locale = Locale(identifier: "en_US_POSIX")
            if let date = customFormatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date string: \(dateString)"
            )
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw HttpClientError.decodingError(error)
        }
    }
}

// MARK: - URLSessionDelegate

extension HttpClient: URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // Bypass SSL certificate validation
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

// MARK: - Errores

enum HttpClientError: LocalizedError {
    case invalidResponse
    case unauthorized
    case httpError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .unauthorized:
            return "Unauthorized - Invalid credentials"
        case .httpError(let statusCode):
            return "HTTP Error: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
    
    var isUnauthorized: Bool {
        if case .unauthorized = self {
            return true
        }
        return false
    }
}
