@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class DecisionDetailsViewModelAsyncTests: XCTestCase {
    private func makeDecisionResponse(id: Int = 1) -> DecisionItemResponse {
        DecisionItemResponse(
            id: id, alertId: 1, origin: "cs", type: "ban", scope: "ip",
            value: "1.2.3.4", expiration: "1h", scenario: "s1", simulated: false,
            source: DecisionItemResponse_Source(asName: nil, asNumber: nil, cn: nil, ip: nil, latitude: nil, longitude: nil, range: nil, scope: "ip", value: "1.2.3.4"),
            crowdsecCreatedAt: "2026-01-01T00:00:00Z",
            alert: DecisionItemResponse_Alert(
                id: 1, uuid: "u", scenario: "s", scenarioVersion: "v", scenarioHash: "h",
                message: "m", capacity: 0, leakspeed: "0", simulated: false, remediation: false,
                eventsCount: 0, machineId: "m",
                source: DecisionItemResponse_Source(asName: nil, asNumber: nil, cn: nil, ip: nil, latitude: nil, longitude: nil, range: nil, scope: "ip", value: "0.0.0.0"),
                meta: [], events: [],
                crowdsecCreatedAt: "2026-01-01T00:00:00Z", startAt: "2026-01-01T00:00:00Z", stopAt: "2026-01-01T00:00:00Z"
            )
        )
    }

    func testFetchDataSuccess() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/decisions/1"] = TestViewModelFactory.encode(makeDecisionResponse())
        let sut = DecisionDetailsViewModel(decisionId: 1, activeServerRepository: activeRepo)
        await sut.fetchData()
        if case .success(let data) = sut.state {
            XCTAssertEqual(data.id, 1)
        } else { XCTFail("Expected success") }
    }

    func testFetchDataFailure() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/decisions/1"] = HttpClientError.httpError(statusCode: 500)
        let sut = DecisionDetailsViewModel(decisionId: 1, activeServerRepository: activeRepo)
        await sut.fetchData()
        if case .failure = sut.state { } else { XCTFail("Expected failure") }
    }

    func testFetchDataWithShowLoading() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/decisions/1"] = TestViewModelFactory.encode(makeDecisionResponse())
        let sut = DecisionDetailsViewModel(decisionId: 1, activeServerRepository: activeRepo)
        await sut.fetchData(showLoading: true)
        if case .success = sut.state { } else { XCTFail("Expected success") }
    }

    func testUpdateDecisionIdChangesId() {
        let (_, _, activeRepo) = TestViewModelFactory.makeStack()
        let sut = DecisionDetailsViewModel(decisionId: 1, activeServerRepository: activeRepo)
        sut.updateDecisionId(decisionId: 2)
        XCTAssertEqual(sut.decisionId, 2)
    }

    func testFetchDataNoServerIsNoOp() async {
        let sut = DecisionDetailsViewModel(decisionId: 1, activeServerRepository: MockActiveServerRepository())
        await sut.fetchData()
        if case .loading = sut.state { } else { XCTFail("Expected loading") }
    }
}
