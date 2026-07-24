@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class IPsCheckerViewModelAsyncTests: XCTestCase {
    func testValidateIpsAllowlistSuccess() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/allowlists/check"] = TestViewModelFactory.encode(
            AllowlistsCheckIPsResponse(results: [
                AllowlistsCheckIPsResponse_Result(ip: "1.2.3.4", allowlist: "my-list"),
            ])
        )
        let sut = IPsCheckerViewModel(activeServerRepository: activeRepo)
        sut.selectedListType = .allowlist
        sut.ipsToCheck = [IPField(value: "1.2.3.4")]
        sut.validateIps()
        try? await Task.sleep(nanoseconds: 300_000_000)
        if case .success(let data) = sut.stateAllowlists {
            XCTAssertEqual(data.results.count, 1)
            XCTAssertEqual(data.results.first?.ip, "1.2.3.4")
        } else { XCTFail("Expected success") }
    }

    func testValidateIpsBlocklistSuccess() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/blocklists/check"] = TestViewModelFactory.encode(
            BlocklistsCheckIPsResponse(results: [
                BlocklistsCheckIPsResponse_Result(ip: "1.2.3.4", blocklists: ["b1"]),
            ])
        )
        let sut = IPsCheckerViewModel(activeServerRepository: activeRepo)
        sut.selectedListType = .blocklist
        sut.ipsToCheck = [IPField(value: "1.2.3.4")]
        sut.validateIps()
        try? await Task.sleep(nanoseconds: 300_000_000)
        if case .success(let data) = sut.stateBlocklists {
            XCTAssertEqual(data.results.count, 1)
            XCTAssertEqual(data.results.first?.blocklists, ["b1"])
        } else { XCTFail("Expected success") }
    }

    func testValidateIpsAllowlistFailure() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/allowlists/check"] = HttpClientError.httpError(statusCode: 500)
        let sut = IPsCheckerViewModel(activeServerRepository: activeRepo)
        sut.selectedListType = .allowlist
        sut.ipsToCheck = [IPField(value: "1.2.3.4")]
        sut.validateIps()
        try? await Task.sleep(nanoseconds: 300_000_000)
        if case .failure = sut.stateAllowlists { } else { XCTFail("Expected failure") }
    }

    func testValidateIpsBlocklistFailure() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/blocklists/check"] = HttpClientError.httpError(statusCode: 500)
        let sut = IPsCheckerViewModel(activeServerRepository: activeRepo)
        sut.selectedListType = .blocklist
        sut.ipsToCheck = [IPField(value: "1.2.3.4")]
        sut.validateIps()
        try? await Task.sleep(nanoseconds: 300_000_000)
        if case .failure = sut.stateBlocklists { } else { XCTFail("Expected failure") }
    }

    func testValidateIpsNoServerIsNoOp() async {
        let sut = IPsCheckerViewModel(activeServerRepository: MockActiveServerRepository())
        sut.ipsToCheck = [IPField(value: "1.2.3.4")]
        sut.validateIps()
        try? await Task.sleep(nanoseconds: 200_000_000)
        if case .loading = sut.stateAllowlists { } else { XCTFail("Expected unchanged loading") }
    }

    func testValidateIPv6() {
        let sut = IPsCheckerViewModel(activeServerRepository: MockActiveServerRepository())
        sut.addEntry()
        sut.ipsToCheck[0].value = "::1"
        sut.validateIP(0)
        XCTAssertFalse(sut.ipsToCheck[0].invalid)
    }
}
