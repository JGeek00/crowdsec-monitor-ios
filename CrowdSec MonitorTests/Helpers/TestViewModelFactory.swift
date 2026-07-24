@testable import CrowdSec_Monitor
import Foundation

/// Helper to build the MockHttpClient → CrowdSecAPIClient → MockActiveServerRepository chain
/// with minimal boilerplate in ViewModel tests.
@MainActor
enum TestViewModelFactory {
    /// Creates a (mockHttp, apiClient, activeRepo) tuple wired for async ViewModel testing.
    /// Set `mockHttp.stubbedResponsesByEndpoint[...]` before calling the ViewModel's async methods.
    static func makeStack() -> (MockHttpClient, CrowdSecAPIClient, MockActiveServerRepository) {
        let mockHttp = MockHttpClient()
        let apiClient = CrowdSecAPIClient(httpClient: mockHttp)
        let activeRepo = MockActiveServerRepository(mockApiClient: apiClient)
        return (mockHttp, apiClient, activeRepo)
    }

    /// Encodes a Codable value to JSON Data for stubbing.
    /// Uses ISO 8601 with fractional seconds to match JSONDecoder.api's expected format.
    static func encode<T: Encodable>(_ value: T) -> Data {
        let encoder = JSONEncoder()
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(isoFormatter.string(from: date))
        }
        return try! encoder.encode(value)
    }
}
