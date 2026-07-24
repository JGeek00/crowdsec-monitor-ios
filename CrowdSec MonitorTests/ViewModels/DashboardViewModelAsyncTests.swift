@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class DashboardViewModelAsyncTests: XCTestCase {
    private func makeStats() -> StatisticsResponse {
        StatisticsResponse(
            alertsLast24Hours: 10,
            activeDecisions: 5,
            activityHistory: [ActivityHistory(date: "2026-01-01", amountAlerts: 3, amountDecisions: 2)],
            topCountries: [TopCountry(countryCode: "US", amount: 5)],
            topScenarios: [TopScenario(scenario: "s1", amount: 3)],
            topIpOwners: [TopIPOwner(ipOwner: "o1", amount: 2)],
            topTargets: [TopTarget(target: "t1", amount: 1)]
        )
    }

    func testFetchDashboardDataSuccess() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/statistics"] = TestViewModelFactory.encode(makeStats())
        let sut = DashboardViewModel(activeServerRepository: activeRepo)
        await sut.fetchDashboardData()
        if case .success(let data) = sut.state {
            XCTAssertEqual(data.alertsLast24Hours, 10)
            XCTAssertEqual(data.activeDecisions, 5)
        } else { XCTFail("Expected success") }
    }

    func testFetchDashboardDataFailure() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/statistics"] = HttpClientError.httpError(statusCode: 500)
        let sut = DashboardViewModel(activeServerRepository: activeRepo)
        await sut.fetchDashboardData()
        if case .failure = sut.state { } else { XCTFail("Expected failure") }
    }

    func testFetchDashboardDataCancellationIsSwallowed() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/statistics"] = CancellationError()
        let sut = DashboardViewModel(activeServerRepository: activeRepo)
        sut.state = .success(makeStats())
        await sut.fetchDashboardData()
        if case .success = sut.state { } else { XCTFail("Expected unchanged") }
    }

    func testResetSetsLoading() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/statistics"] = TestViewModelFactory.encode(makeStats())
        let sut = DashboardViewModel(activeServerRepository: activeRepo)
        await sut.fetchDashboardData()
        sut.reset()
        if case .loading = sut.state { } else { XCTFail("Expected loading") }
    }

    func testFetchDashboardDataNoServerIsNoOp() async {
        let sut = DashboardViewModel(activeServerRepository: MockActiveServerRepository())
        await sut.fetchDashboardData()
        if case .loading = sut.state { } else { XCTFail("Expected loading") }
    }

    func testServiceStatusStatePassthrough() {
        let (_, _, activeRepo) = TestViewModelFactory.makeStack()
        let statusRepo = ServiceStatusRepository(activeServerRepository: activeRepo)
        let sut = DashboardViewModel(
            activeServerRepository: activeRepo,
            serversManagerRepository: RepositoriesContainer.shared.serversManagerRepository,
            serviceStatusRepository: statusRepo
        )
        if case .loading = sut.serviceStatusState { } else { XCTFail("Expected loading") }
    }
}
