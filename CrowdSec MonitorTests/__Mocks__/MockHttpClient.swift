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
    /// The last endpoint that was called.
    private(set) var capturedEndpoint: String?
    /// The last query params that were passed.
    private(set) var capturedQueryParams: [URLQueryItem]?

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
        capturedEndpoint = endpoint
        capturedQueryParams = queryParams
        if let error = stubbedError { throw error }
        let data = stubbedResponseData ?? Data()
        let body: T = try decode(data)
        return HttpResponse(successful: (200...299).contains(stubbedStatusCode), statusCode: stubbedStatusCode, body: body)
    }

    override func delete<T: Decodable>(
        endpoint: String,
        queryParams: [URLQueryItem]? = nil
    ) async throws -> HttpResponse<T> {
        capturedEndpoint = endpoint
        capturedQueryParams = queryParams
        if let error = stubbedError { throw error }
        let data = stubbedResponseData ?? Data()
        let body: T = try decode(data)
        return HttpResponse(successful: (200...299).contains(stubbedStatusCode), statusCode: stubbedStatusCode, body: body)
    }

    override func post<T: Encodable, R: Decodable>(
        endpoint: String,
        body: T
    ) async throws -> HttpResponse<R> {
        capturedEndpoint = endpoint
        if let error = stubbedError { throw error }
        let data = stubbedResponseData ?? Data()
        let decodedBody: R = try decode(data)
        return HttpResponse(successful: (200...299).contains(stubbedStatusCode), statusCode: stubbedStatusCode, body: decodedBody)
    }

    override func post<R: Decodable>(
        endpoint: String
    ) async throws -> HttpResponse<R> {
        capturedEndpoint = endpoint
        if let error = stubbedError { throw error }
        let data = stubbedResponseData ?? Data()
        let decodedBody: R = try decode(data)
        return HttpResponse(successful: (200...299).contains(stubbedStatusCode), statusCode: stubbedStatusCode, body: decodedBody)
    }
}
