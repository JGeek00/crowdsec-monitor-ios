@testable import CrowdSec_Monitor
import Foundation

/// Test double for `ActiveServerRepository` that provides a stubbable `apiClient`.
/// ponytail: uses subclass override instead of protocol extraction.
@MainActor
final class MockActiveServerRepository: ActiveServerRepository {
    let mockApiClient: CrowdSecAPIClient?

    init(mockApiClient: CrowdSecAPIClient? = nil) {
        self.mockApiClient = mockApiClient
        super.init()
    }

    override var apiClient: CrowdSecAPIClient? {
        get { mockApiClient }
        set { /* no-op in tests */ }
    }

    override var currentServer: CSServer? {
        get { mockApiClient != nil ? super.currentServer : nil }
        set { super.currentServer = newValue }
    }

    override var hasServerConfigured: Bool {
        mockApiClient != nil
    }
}
