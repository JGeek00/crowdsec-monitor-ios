@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class FullListDashboardItemViewModelAsyncTests: XCTestCase {
    func testFetchDataCountrySuccess() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/statistics/countries"] = TestViewModelFactory.encode([
            TopCountry(countryCode: "US", amount: 100),
            TopCountry(countryCode: "ES", amount: 50),
        ])
        let sut = FullListDashboardItemViewModel(dashboardItem: .country, activeServerRepository: activeRepo)
        await sut.fetchData()
        if case .success(let data) = sut.state {
            XCTAssertEqual(data.count, 2)
            XCTAssertEqual(data[0].item, "US")
            XCTAssertEqual(data[0].value, 100)
        } else { XCTFail("Expected success") }
    }

    func testFetchDataIpOwnerSuccess() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/statistics/ip-owners"] = TestViewModelFactory.encode([
            TopIPOwner(ipOwner: "owner1", amount: 10),
        ])
        let sut = FullListDashboardItemViewModel(dashboardItem: .ipOwner, activeServerRepository: activeRepo)
        await sut.fetchData()
        if case .success(let data) = sut.state {
            XCTAssertEqual(data.count, 1)
            XCTAssertEqual(data[0].item, "owner1")
        } else { XCTFail("Expected success") }
    }

    func testFetchDataScenarioSuccess() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/statistics/scenarios"] = TestViewModelFactory.encode([
            TopScenario(scenario: "scen1", amount: 5),
        ])
        let sut = FullListDashboardItemViewModel(dashboardItem: .scenary, activeServerRepository: activeRepo)
        await sut.fetchData()
        if case .success = sut.state { } else { XCTFail("Expected success") }
    }

    func testFetchDataTargetSuccess() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/statistics/targets"] = TestViewModelFactory.encode([
            TopTarget(target: "t1", amount: 3),
        ])
        let sut = FullListDashboardItemViewModel(dashboardItem: .target, activeServerRepository: activeRepo)
        await sut.fetchData()
        if case .success = sut.state { } else { XCTFail("Expected success") }
    }

    func testFetchDataFailure() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/statistics/countries"] = HttpClientError.httpError(statusCode: 500)
        let sut = FullListDashboardItemViewModel(dashboardItem: .country, activeServerRepository: activeRepo)
        await sut.fetchData()
        if case .failure = sut.state { } else { XCTFail("Expected failure") }
    }

    func testFetchDataNoServerIsNoOp() async {
        let activeRepo = MockActiveServerRepository() // no apiClient
        let sut = FullListDashboardItemViewModel(dashboardItem: .country, activeServerRepository: activeRepo)
        await sut.fetchData()
        if case .loading = sut.state { } else { XCTFail("Expected loading (no-op)") }
    }

    func testChartDataWithFewerItemsThanColors() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/statistics/countries"] = TestViewModelFactory.encode([
            TopCountry(countryCode: "US", amount: 100),
        ])
        let sut = FullListDashboardItemViewModel(dashboardItem: .country, activeServerRepository: activeRepo)
        await sut.fetchData()
        XCTAssertEqual(sut.chartData.count, 1)
    }

    func testChartDataWithMoreItemsThanColorsCollapsesToOtros() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        // colors.count = 12, so pass 15 items
        let items = (0..<15).map { TopCountry(countryCode: "C\($0)", amount: $0 + 1) }
        mockHttp.stubbedResponsesByEndpoint["/api/v1/statistics/countries"] = TestViewModelFactory.encode(items)
        let sut = FullListDashboardItemViewModel(dashboardItem: .country, activeServerRepository: activeRepo)
        await sut.fetchData()
        // Should be 12 colored + 1 "Otros" = 13
        XCTAssertEqual(sut.chartData.count, 13)
        XCTAssertEqual(sut.chartData.last?.item, "Otros")
    }

    func testChartDataEmptyWhenLoading() {
        let sut = FullListDashboardItemViewModel(dashboardItem: .country, activeServerRepository: MockActiveServerRepository())
        XCTAssertTrue(sut.chartData.isEmpty)
    }

    func testChartDataPercentageCalculation() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/statistics/countries"] = TestViewModelFactory.encode([
            TopCountry(countryCode: "US", amount: 75),
            TopCountry(countryCode: "ES", amount: 25),
        ])
        let sut = FullListDashboardItemViewModel(dashboardItem: .country, activeServerRepository: activeRepo)
        await sut.fetchData()
        if case .success = sut.state {
            XCTAssertEqual(sut.chartData[0].percentage, 0.75, accuracy: 0.01)
            XCTAssertEqual(sut.chartData[1].percentage, 0.25, accuracy: 0.01)
        } else { XCTFail("Expected success") }
    }

    func testChartDataZeroTotalDoesNotDivideByZero() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/statistics/countries"] = TestViewModelFactory.encode([
            TopCountry(countryCode: "US", amount: 0),
        ])
        let sut = FullListDashboardItemViewModel(dashboardItem: .country, activeServerRepository: activeRepo)
        await sut.fetchData()
        if case .success = sut.state {
            XCTAssertEqual(sut.chartData[0].percentage, 0.0)
        } else { XCTFail("Expected success") }
    }
}
