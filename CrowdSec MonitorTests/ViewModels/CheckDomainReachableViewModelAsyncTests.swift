@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class CheckDomainReachableViewModelAsyncTests: XCTestCase {
    func testCheckDomainSuccess() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/blocklists/check-domain"] = TestViewModelFactory.encode(
            BlocklistsCheckDomainResponse(domain: "example.com", ips: [
                BlocklistsCheckDomainResponse_IP(ip: "1.2.3.4", blocklists: ["b1"]),
            ])
        )
        let sut = CheckDomainReachableViewModel(activeServerRepository: activeRepo)
        sut.domain = "example.com"
        sut.checkDomain()
        try? await Task.sleep(nanoseconds: 300_000_000)
        XCTAssertFalse(sut.loading)
        XCTAssertFalse(sut.error)
        XCTAssertFalse(sut.domainNotResolvable)
        XCTAssertNotNil(sut.data)
        XCTAssertEqual(sut.data?.domain, "example.com")
    }

    func testCheckDomain422SetsDomainNotResolvable() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/blocklists/check-domain"] = HttpClientError.httpErrorWithMessage(statusCode: 422, message: "not resolvable")
        let sut = CheckDomainReachableViewModel(activeServerRepository: activeRepo)
        sut.domain = "nonexistent.com"
        sut.checkDomain()
        try? await Task.sleep(nanoseconds: 300_000_000)
        XCTAssertTrue(sut.domainNotResolvable)
        XCTAssertFalse(sut.error)
        XCTAssertFalse(sut.loading)
        XCTAssertNil(sut.data)
    }

    func testCheckDomainGenericErrorSetsError() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/blocklists/check-domain"] = HttpClientError.httpError(statusCode: 500)
        let sut = CheckDomainReachableViewModel(activeServerRepository: activeRepo)
        sut.domain = "example.com"
        sut.checkDomain()
        try? await Task.sleep(nanoseconds: 300_000_000)
        XCTAssertTrue(sut.error)
        XCTAssertFalse(sut.domainNotResolvable)
        XCTAssertFalse(sut.loading)
        XCTAssertNil(sut.data)
    }

    func testCheckDomainNoServerIsNoOp() async {
        let sut = CheckDomainReachableViewModel(activeServerRepository: MockActiveServerRepository())
        sut.domain = "example.com"
        sut.checkDomain()
        try? await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertFalse(sut.loading)
        XCTAssertFalse(sut.error)
        XCTAssertNil(sut.data)
    }
}
