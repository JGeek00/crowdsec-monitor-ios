@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class AllowlistsListViewModelTests: XCTestCase {
    func testStateLoadingByDefault() {
        let sut = AllowlistsListViewModel(activeServerRepository: MockActiveServerRepository())
        if case .loading = sut.state {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected loading state")
        }
    }
}
