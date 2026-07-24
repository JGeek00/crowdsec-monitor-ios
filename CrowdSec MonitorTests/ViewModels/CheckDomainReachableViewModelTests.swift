@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class CheckDomainReachableViewModelTests: XCTestCase {
    func testDefaultValues() {
        let sut = CheckDomainReachableViewModel(activeServerRepository: MockActiveServerRepository())
        XCTAssertEqual(sut.domain, "")
        XCTAssertFalse(sut.invalidDomainAlert)
        XCTAssertFalse(sut.loading)
    }

    func testCheckDomainFailsWithEmptyDomain() async {
        let sut = CheckDomainReachableViewModel(activeServerRepository: MockActiveServerRepository())
        await sut.checkDomain()
        XCTAssertTrue(sut.invalidDomainAlert)
    }

    func testCheckDomainFailsWithInvalidDomain() async {
        let sut = CheckDomainReachableViewModel(activeServerRepository: MockActiveServerRepository())
        sut.domain = "not a domain!!!"
        await sut.checkDomain()
        XCTAssertTrue(sut.invalidDomainAlert)
    }
}
