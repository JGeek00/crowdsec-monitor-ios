@testable import CrowdSec_Monitor
import Foundation

/// A test double for `HttpClient` that never hits the network.
/// Captures request parameters and returns stubbed responses.
// Use #warning instead of a real init to document the super init call is deliberate.
@MainActor
final class MockHttpClient: HttpClient {
    /// Init with dummy values — the mock never hits the network.
    init() {
        super.init(
            connectionMethod: "http",
            ipDomain: "localhost",
            port: 8080,
            path: nil,
            authMethod: nil,
            basicUser: nil,
            basicPassword: nil,
            bearerToken: nil
        )
    }

    /// Set by the test to return canned data for the next call.
    var stubbedResponseData: Data?
    /// HTTP status code for the stubbed response.
    var stubbedStatusCode: Int = 200
    /// Error to throw instead of returning a response.
    var stubbedError: Error?
    /// Per-endpoint stubbed responses. Key = endpoint path (e.g. "/api/v1/blocklists").
    /// If the endpoint is present here, it takes precedence over `stubbedResponseData`.
    var stubbedResponsesByEndpoint: [String: Data] = [:]
    /// Per-endpoint stubbed status codes. Falls back to `stubbedStatusCode` if absent.
    var stubbedStatusCodesByEndpoint: [String: Int] = [:]
    /// Per-endpoint errors. If the endpoint is present, throws instead of returning data.
    /// Takes precedence over `stubbedError` and `stubbedResponsesByEndpoint`.
    var stubbedErrorsByEndpoint: [String: Error] = [:]
    /// The last endpoint that was called.
    private(set) var capturedEndpoint: String?
    /// The last query params that were passed.
    private(set) var capturedQueryParams: [URLQueryItem]?
    /// All endpoints called, in order.
    private(set) var capturedEndpoints: [String] = []

    private func response(for endpoint: String) throws -> (Data, Int) {
        capturedEndpoint = endpoint
        capturedEndpoints.append(endpoint)
        if let error = stubbedErrorsByEndpoint[endpoint] { throw error }
        if let error = stubbedError { throw error }
        let data = stubbedResponsesByEndpoint[endpoint] ?? stubbedResponseData ?? Data()
        let statusCode = stubbedStatusCodesByEndpoint[endpoint] ?? stubbedStatusCode
        return (data, statusCode)
    }

    /// ponytail: mirrors HttpClient.decode() — wraps DecodingError in HttpClientError.decodingError
    private func decode<T: Decodable>(_ data: Data) throws -> T {
        do {
            return try JSONDecoder.api.decode(T.self, from: data)
        } catch {
            throw HttpClientError.decodingError(error)
        }
    }

    override func get<T: Decodable>(
        endpoint: String,
        queryParams: [URLQueryItem]? = nil
    ) async throws -> HttpResponse<T> {
        capturedQueryParams = queryParams
        let (data, statusCode) = try response(for: endpoint)
        let body: T = try decode(data)
        return HttpResponse(successful: (200...299).contains(statusCode), statusCode: statusCode, body: body)
    }

    override func delete<T: Decodable>(
        endpoint: String,
        queryParams: [URLQueryItem]? = nil
    ) async throws -> HttpResponse<T> {
        capturedQueryParams = queryParams
        let (data, statusCode) = try response(for: endpoint)
        let body: T = try decode(data)
        return HttpResponse(successful: (200...299).contains(statusCode), statusCode: statusCode, body: body)
    }

    override func post<T: Encodable, R: Decodable>(
        endpoint: String,
        body: T
    ) async throws -> HttpResponse<R> {
        let (data, statusCode) = try response(for: endpoint)
        let decodedBody: R = try decode(data)
        return HttpResponse(successful: (200...299).contains(statusCode), statusCode: statusCode, body: decodedBody)
    }

    override func post<R: Decodable>(
        endpoint: String
    ) async throws -> HttpResponse<R> {
        let (data, statusCode) = try response(for: endpoint)
        let decodedBody: R = try decode(data)
        return HttpResponse(successful: (200...299).contains(statusCode), statusCode: statusCode, body: decodedBody)
    }
}
