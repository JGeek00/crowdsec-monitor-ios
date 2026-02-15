import Foundation

// MARK: - HTTP Response Structure

struct HttpResponse<T: Decodable>: Decodable {
    let successful: Bool
    let statusCode: Int
    let body: T
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
        do {
            return try JSONDecoder().decode(T.self, from: data)
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
