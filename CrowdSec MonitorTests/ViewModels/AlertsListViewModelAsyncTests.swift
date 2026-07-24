@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class AlertsListViewModelAsyncTests: XCTestCase {
    private func makeAlert(id: Int) -> AlertsListResponse_Alert {
        AlertsListResponse_Alert(
            id: id, uuid: "uuid-\(id)", scenario: "s1", scenarioVersion: "v1", scenarioHash: "h1",
            message: "msg", capacity: 1, leakspeed: "1", simulated: false, remediation: false,
            eventsCount: 1, machineID: "m1",
            source: AlertsListResponse_Alert_Source(asName: nil, asNumber: nil, cn: nil, ip: nil, latitude: nil, longitude: nil, range: nil, scope: "ip", value: "1.2.3.4"),
            meta: [], events: [],
            crowdsecCreatedAt: "2026-01-01T00:00:00Z", startAt: "2026-01-01T00:00:00Z", stopAt: "2026-01-01T00:00:00Z"
        )
    }

    private func makeResponse(items: [AlertsListResponse_Alert], page: Int = 1, total: Int = 100) -> AlertsListResponse {
        AlertsListResponse(
            filtering: AlertsListResponse_Filtering(countries: [], scenarios: [], ipOwners: [], targets: []),
            items: items,
            pagination: AlertsListResponse_Pagination(page: page, amount: 50, total: total)
        )
    }

    func testInitialFetchAlertsSuccess() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/alerts"] = TestViewModelFactory.encode(
            makeResponse(items: [makeAlert(id: 1), makeAlert(id: 2)])
        )
        let sut = AlertsListViewModel(activeServerRepository: activeRepo)
        await sut.initialFetchAlerts()
        if case .success(let data) = sut.state {
            XCTAssertEqual(data.items.count, 2)
        } else { XCTFail("Expected success") }
    }

    func testInitialFetchWhenDataPresentIsNoOp() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/alerts"] = TestViewModelFactory.encode(
            makeResponse(items: [makeAlert(id: 99)])
        )
        let sut = AlertsListViewModel(activeServerRepository: activeRepo)
        sut.state = .success(makeResponse(items: [makeAlert(id: 1)]))
        await sut.initialFetchAlerts()
        if case .success(let data) = sut.state {
            XCTAssertEqual(data.items.first?.id, 1) // unchanged
        } else { XCTFail("Expected unchanged") }
    }

    func testFetchAlertsFailure() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/alerts"] = HttpClientError.httpError(statusCode: 500)
        let sut = AlertsListViewModel(activeServerRepository: activeRepo)
        await sut.initialFetchAlerts()
        if case .failure = sut.state { } else { XCTFail("Expected failure") }
    }

    func testFetchAlertsCancellationIsSwallowed() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/alerts"] = CancellationError()
        let sut = AlertsListViewModel(activeServerRepository: activeRepo)
        sut.state = .success(makeResponse(items: [makeAlert(id: 1)]))
        await sut.initialFetchAlerts()
        if case .success = sut.state { } else { XCTFail("Expected unchanged") }
    }

    func testFetchMoreDeduplicatesByID() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        let sut = AlertsListViewModel(activeServerRepository: activeRepo)
        sut.state = .success(makeResponse(items: [makeAlert(id: 1), makeAlert(id: 2)], page: 1, total: 100))
        mockHttp.stubbedResponsesByEndpoint["/api/v1/alerts"] = TestViewModelFactory.encode(
            makeResponse(items: [makeAlert(id: 2), makeAlert(id: 3)], page: 2, total: 100)
        )
        await sut.fetchMore()
        if case .success(let data) = sut.state {
            XCTAssertEqual(data.items.count, 3)
            XCTAssertEqual(data.items.map(\.id).sorted(), [1, 2, 3])
        } else { XCTFail("Expected success") }
    }

    func testFetchMoreWhenPaginationReachedIsNoOp() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        let sut = AlertsListViewModel(activeServerRepository: activeRepo)
        sut.state = .success(makeResponse(items: [makeAlert(id: 1)], page: 2, total: 100))
        await sut.fetchMore()
        if case .success(let data) = sut.state {
            XCTAssertEqual(data.items.count, 1) // unchanged
        } else { XCTFail("Expected unchanged") }
    }

    func testDeleteAlertSuccessClearsSelectedAndReturnsTrue() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/alerts/5"] = Data("{}".utf8)
        mockHttp.stubbedResponsesByEndpoint["/api/v1/alerts"] = TestViewModelFactory.encode(
            makeResponse(items: [])
        )
        let sut = AlertsListViewModel(activeServerRepository: activeRepo)
        sut.selectedAlert = 5
        let result = await sut.deleteAlert(alertId: 5)
        XCTAssertTrue(result)
        XCTAssertNil(sut.selectedAlert)
        XCTAssertFalse(sut.deletingAlertProcess)
    }

    func testDeleteAlertFailureReturnsFalse() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/alerts/5"] = HttpClientError.httpError(statusCode: 500)
        let sut = AlertsListViewModel(activeServerRepository: activeRepo)
        let result = await sut.deleteAlert(alertId: 5)
        XCTAssertFalse(result)
        XCTAssertFalse(sut.deletingAlertProcess)
    }

    func testRefreshAlertsSuccess() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/alerts"] = TestViewModelFactory.encode(
            makeResponse(items: [makeAlert(id: 1)])
        )
        let sut = AlertsListViewModel(activeServerRepository: activeRepo)
        await sut.refreshAlerts()
        if case .success = sut.state { } else { XCTFail("Expected success") }
    }

    func testUpdateFilters() {
        let sut = AlertsListViewModel(activeServerRepository: MockActiveServerRepository())
        let newFilters = AlertsRequestFilters(countries: ["US"], scenarios: [], ipOwners: [], targets: [])
        sut.updateFilters(newFilters)
        XCTAssertEqual(sut.filters.countries, ["US"])
    }

    func testResetFiltersPanelToAppliedOnes() {
        let sut = AlertsListViewModel(activeServerRepository: MockActiveServerRepository())
        sut.requestParams.filters = AlertsRequestFilters(countries: ["US"], scenarios: [], ipOwners: [], targets: [])
        sut.filters = AlertsRequestFilters(countries: [], scenarios: [], ipOwners: [], targets: [])
        sut.resetFiltersPanelToAppliedOnes()
        XCTAssertEqual(sut.filters.countries, sut.requestParams.filters.countries)
    }

    func testResetClearsState() {
        let sut = AlertsListViewModel(activeServerRepository: MockActiveServerRepository())
        sut.selectedAlert = 5
        sut.deletingAlertProcess = true
        sut.reset()
        XCTAssertNil(sut.selectedAlert)
        XCTAssertFalse(sut.deletingAlertProcess)
        if case .loading = sut.state { } else { XCTFail("Expected loading") }
    }

    func testFetchNoServerIsNoOp() async {
        let sut = AlertsListViewModel(activeServerRepository: MockActiveServerRepository())
        await sut.initialFetchAlerts()
        if case .loading = sut.state { } else { XCTFail("Expected loading") }
    }
}
