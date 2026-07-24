@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class AlertDetailsViewModelAsyncTests: XCTestCase {
    func testFetchDataSuccess() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        let response = AlertDetailsResponse(
            id: 1, uuid: "uuid-1", scenario: "s1", scenarioVersion: "v1", scenarioHash: "h1",
            message: "msg", capacity: 1, leakspeed: "1", simulated: false, remediation: false,
            eventsCount: 1, machineID: "m1",
            source: AlertDetailsResponse_Source(asName: nil, asNumber: nil, cn: nil, ip: nil, latitude: nil, longitude: nil, range: nil, scope: "ip", value: "1.2.3.4"),
            meta: [], events: [],
            crowdsecCreatedAt: Date(), startAt: Date(), stopAt: Date(),
            decisions: []
        )
        mockHttp.stubbedResponsesByEndpoint["/api/v1/alerts/1"] = TestViewModelFactory.encode(response)
        let sut = AlertDetailsViewModel(alertId: 1, activeServerRepository: activeRepo)
        await sut.fetchData()
        if case .success(let data) = sut.state {
            XCTAssertEqual(data.id, 1)
        } else { XCTFail("Expected success") }
    }

    func testFetchDataFailure() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/alerts/1"] = HttpClientError.httpError(statusCode: 500)
        let sut = AlertDetailsViewModel(alertId: 1, activeServerRepository: activeRepo)
        await sut.fetchData()
        if case .failure = sut.state { } else { XCTFail("Expected failure") }
    }

    func testFetchDataWithShowLoading() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        let response = AlertDetailsResponse(
            id: 1, uuid: "u", scenario: "s", scenarioVersion: "v", scenarioHash: "h",
            message: "m", capacity: 0, leakspeed: "0", simulated: false, remediation: false,
            eventsCount: 0, machineID: "m",
            source: AlertDetailsResponse_Source(asName: nil, asNumber: nil, cn: nil, ip: nil, latitude: nil, longitude: nil, range: nil, scope: "ip", value: "0.0.0.0"),
            meta: [], events: [],
            crowdsecCreatedAt: Date(), startAt: Date(), stopAt: Date(),
            decisions: []
        )
        mockHttp.stubbedResponsesByEndpoint["/api/v1/alerts/1"] = TestViewModelFactory.encode(response)
        let sut = AlertDetailsViewModel(alertId: 1, activeServerRepository: activeRepo)
        await sut.fetchData(showLoading: true)
        if case .success = sut.state { } else { XCTFail("Expected success") }
    }

    func testUpdateAlertIdChangesId() {
        let (_, _, activeRepo) = TestViewModelFactory.makeStack()
        let sut = AlertDetailsViewModel(alertId: 1, activeServerRepository: activeRepo)
        sut.updateAlertId(alertId: 2)
        XCTAssertEqual(sut.alertId, 2)
    }

    func testFetchDataNoServerIsNoOp() async {
        let sut = AlertDetailsViewModel(alertId: 1, activeServerRepository: MockActiveServerRepository())
        await sut.fetchData()
        if case .loading = sut.state { } else { XCTFail("Expected loading") }
    }
}
