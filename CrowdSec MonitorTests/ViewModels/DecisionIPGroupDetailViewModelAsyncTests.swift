@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class DecisionIPGroupDetailViewModelAsyncTests: XCTestCase {
    private func makeResponse(ip: String = "1.2.3.4") -> DecisionsByIPDetailResponse {
        DecisionsByIPDetailResponse(
            ip: ip, country: nil, owner: nil, asNumber: nil,
            latitude: nil, longitude: nil, range: "32",
            activeDecisions: 1, totalDecisions: 1,
            decisions: []
        )
    }

    func testFetchDataSuccess() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/decisions/by-ip/1.2.3.4"] = TestViewModelFactory.encode(makeResponse())
        let sut = DecisionIPGroupDetailViewModel(ip: "1.2.3.4", onlyActive: true, activeServerRepository: activeRepo)
        await sut.fetchData()
        if case .success(let data) = sut.state {
            XCTAssertEqual(data.ip, "1.2.3.4")
        } else { XCTFail("Expected success") }
    }

    func testFetchDataFailure() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/decisions/by-ip/1.2.3.4"] = HttpClientError.httpError(statusCode: 500)
        let sut = DecisionIPGroupDetailViewModel(ip: "1.2.3.4", onlyActive: true, activeServerRepository: activeRepo)
        await sut.fetchData()
        if case .failure = sut.state { } else { XCTFail("Expected failure") }
    }

    func testFetchDataWithShowLoading() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/decisions/by-ip/1.2.3.4"] = TestViewModelFactory.encode(makeResponse())
        let sut = DecisionIPGroupDetailViewModel(ip: "1.2.3.4", onlyActive: false, activeServerRepository: activeRepo)
        await sut.fetchData(showLoading: true)
        if case .success = sut.state { } else { XCTFail("Expected success") }
    }

    func testExpireDecisionSuccessReturnsTrue() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/decisions/42"] = Data("{}".utf8)
        mockHttp.stubbedResponsesByEndpoint["/api/v1/decisions/by-ip/1.2.3.4"] = TestViewModelFactory.encode(makeResponse())
        let sut = DecisionIPGroupDetailViewModel(ip: "1.2.3.4", onlyActive: true, activeServerRepository: activeRepo)
        let result = await sut.expireDecision(decisionId: 42)
        XCTAssertTrue(result)
        XCTAssertFalse(sut.processingExpireDecision)
    }

    func testExpireDecisionFailureReturnsFalse() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/decisions/42"] = HttpClientError.httpError(statusCode: 500)
        let sut = DecisionIPGroupDetailViewModel(ip: "1.2.3.4", onlyActive: true, activeServerRepository: activeRepo)
        let result = await sut.expireDecision(decisionId: 42)
        XCTAssertFalse(result)
        XCTAssertFalse(sut.processingExpireDecision)
    }

    func testUpdateIPChangesIP() {
        let (_, _, activeRepo) = TestViewModelFactory.makeStack()
        let sut = DecisionIPGroupDetailViewModel(ip: "1.2.3.4", onlyActive: true, activeServerRepository: activeRepo)
        sut.updateIP(ip: "5.6.7.8")
        XCTAssertEqual(sut.ip, "5.6.7.8")
    }

    func testFetchDataNoServerIsNoOp() async {
        let sut = DecisionIPGroupDetailViewModel(ip: "1.2.3.4", onlyActive: true, activeServerRepository: MockActiveServerRepository())
        await sut.fetchData()
        if case .loading = sut.state { } else { XCTFail("Expected loading") }
    }

    func testOnlyActiveValuePreserved() {
        let (_, _, activeRepo) = TestViewModelFactory.makeStack()
        let sut = DecisionIPGroupDetailViewModel(ip: "1.2.3.4", onlyActive: false, activeServerRepository: activeRepo)
        XCTAssertFalse(sut.onlyActive)
    }
}
