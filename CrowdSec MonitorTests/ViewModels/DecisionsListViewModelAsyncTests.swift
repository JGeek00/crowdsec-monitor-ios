@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class DecisionsListViewModelAsyncTests: XCTestCase {
    private func makeDecision(id: Int) -> DecisionsListResponse_Item {
        DecisionsListResponse_Item(
            id: id, alertId: 1, origin: "cs", type: "ban", scope: "ip",
            value: "1.2.3.4", expiration: "1h", scenario: "s1", simulated: false,
            source: DecisionsListResponse_Item_Source(asName: nil, asNumber: nil, cn: nil, ip: nil, latitude: nil, longitude: nil, range: nil, scope: "ip", value: "1.2.3.4"),
            crowdsecCreatedAt: "2026-01-01T00:00:00Z"
        )
    }

    private func makeResponse(items: [DecisionsListResponse_Item], page: Int = 1, total: Int = 100) -> DecisionsListResponse {
        DecisionsListResponse(
            filtering: DecisionsListResponse_Filtering(countries: [], ipOwners: []),
            items: items,
            pagination: DecisionsListResponse_Pagination(page: page, amount: 50, total: total)
        )
    }

    private func makeGroupedResponse(groups: [DecisionsByIPResponse_Group], page: Int = 1, total: Int = 100) -> DecisionsByIPResponse {
        DecisionsByIPResponse(
            filtering: DecisionsListResponse_Filtering(countries: [], ipOwners: []),
            groups: groups,
            pagination: DecisionsListResponse_Pagination(page: page, amount: 50, total: total)
        )
    }

    private func makeGroup(ip: String) -> DecisionsByIPResponse_Group {
        DecisionsByIPResponse_Group(ip: ip, country: nil, owner: nil, asNumber: nil, latitude: nil, longitude: nil, range: "32", activeDecisions: 1, totalDecisions: 1)
    }

    func testInitialFetchDecisionsNonGroupedSuccess() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/decisions"] = TestViewModelFactory.encode(
            makeResponse(items: [makeDecision(id: 1), makeDecision(id: 2)])
        )
        let sut = DecisionsListViewModel(activeServerRepository: activeRepo)
        sut.requestParams.filters.groupByIP = false
        await sut.initialFetchDecisions()
        if case .success(let data) = sut.state {
            XCTAssertEqual(data.items.count, 2)
        } else { XCTFail("Expected success") }
    }

    func testInitialFetchDecisionsGroupedSuccess() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/decisions/by-ip"] = TestViewModelFactory.encode(
            makeGroupedResponse(groups: [makeGroup(ip: "1.2.3.4")])
        )
        let sut = DecisionsListViewModel(activeServerRepository: activeRepo)
        sut.requestParams.filters.groupByIP = true
        await sut.initialFetchDecisions()
        if case .success(let data) = sut.stateByIP {
            XCTAssertEqual(data.groups.count, 1)
        } else { XCTFail("Expected success") }
    }

    func testFetchDecisionsFailure() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/decisions"] = HttpClientError.httpError(statusCode: 500)
        let sut = DecisionsListViewModel(activeServerRepository: activeRepo)
        sut.requestParams.filters.groupByIP = false
        await sut.initialFetchDecisions()
        if case .failure = sut.state { } else { XCTFail("Expected failure") }
    }

    func testFetchDecisionsGroupedFailure() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/decisions/by-ip"] = HttpClientError.httpError(statusCode: 500)
        let sut = DecisionsListViewModel(activeServerRepository: activeRepo)
        sut.requestParams.filters.groupByIP = true
        await sut.initialFetchDecisions()
        if case .failure = sut.stateByIP { } else { XCTFail("Expected failure") }
    }

    func testFetchDecisionsCancellationIsSwallowed() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/decisions"] = CancellationError()
        let sut = DecisionsListViewModel(activeServerRepository: activeRepo)
        sut.requestParams.filters.groupByIP = false
        sut.state = .success(makeResponse(items: [makeDecision(id: 1)]))
        await sut.initialFetchDecisions()
        if case .success = sut.state { } else { XCTFail("Expected unchanged") }
    }

    func testFetchMoreDeduplicatesByID() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        let sut = DecisionsListViewModel(activeServerRepository: activeRepo)
        sut.requestParams.filters.groupByIP = false
        sut.state = .success(makeResponse(items: [makeDecision(id: 1), makeDecision(id: 2)], page: 1, total: 100))
        mockHttp.stubbedResponsesByEndpoint["/api/v1/decisions"] = TestViewModelFactory.encode(
            makeResponse(items: [makeDecision(id: 2), makeDecision(id: 3)], page: 2, total: 100)
        )
        await sut.fetchMore()
        if case .success(let data) = sut.state {
            XCTAssertEqual(data.items.count, 3)
            XCTAssertEqual(data.items.map(\.id).sorted(), [1, 2, 3])
        } else { XCTFail("Expected success") }
    }

    func testFetchMoreGroupedDeduplicatesByIP() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        let sut = DecisionsListViewModel(activeServerRepository: activeRepo)
        sut.requestParams.filters.groupByIP = true
        sut.stateByIP = .success(makeGroupedResponse(groups: [makeGroup(ip: "1.2.3.4"), makeGroup(ip: "5.6.7.8")], page: 1, total: 100))
        mockHttp.stubbedResponsesByEndpoint["/api/v1/decisions/by-ip"] = TestViewModelFactory.encode(
            makeGroupedResponse(groups: [makeGroup(ip: "5.6.7.8"), makeGroup(ip: "9.10.11.12")], page: 2, total: 100)
        )
        await sut.fetchMore()
        if case .success(let data) = sut.stateByIP {
            XCTAssertEqual(data.groups.count, 3)
            XCTAssertEqual(data.groups.map(\.ip).sorted(), ["1.2.3.4", "5.6.7.8", "9.10.11.12"])
        } else { XCTFail("Expected success") }
    }

    func testFetchMoreWhenPaginationReachedIsNoOp() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        let sut = DecisionsListViewModel(activeServerRepository: activeRepo)
        sut.requestParams.filters.groupByIP = false
        sut.state = .success(makeResponse(items: [makeDecision(id: 1)], page: 2, total: 100))
        await sut.fetchMore()
        if case .success(let data) = sut.state {
            XCTAssertEqual(data.items.count, 1) // unchanged
        } else { XCTFail("Expected unchanged") }
    }

    func testExpireDecisionSuccessReturnsTrue() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/decisions/42"] = Data("{}".utf8)
        mockHttp.stubbedResponsesByEndpoint["/api/v1/decisions"] = TestViewModelFactory.encode(
            makeResponse(items: [])
        )
        let sut = DecisionsListViewModel(activeServerRepository: activeRepo)
        sut.requestParams.filters.groupByIP = false
        let result = await sut.expireDecision(decisionId: 42)
        XCTAssertTrue(result)
        XCTAssertFalse(sut.processingExpireDecision)
    }

    func testExpireDecisionFailureReturnsFalse() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/decisions/42"] = HttpClientError.httpError(statusCode: 500)
        let sut = DecisionsListViewModel(activeServerRepository: activeRepo)
        sut.requestParams.filters.groupByIP = false
        let result = await sut.expireDecision(decisionId: 42)
        XCTAssertFalse(result)
        XCTAssertFalse(sut.processingExpireDecision)
    }

    func testRefreshDecisionsSuccess() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/decisions"] = TestViewModelFactory.encode(
            makeResponse(items: [makeDecision(id: 1)])
        )
        let sut = DecisionsListViewModel(activeServerRepository: activeRepo)
        sut.requestParams.filters.groupByIP = false
        await sut.refreshDecisions()
        if case .success = sut.state { } else { XCTFail("Expected success") }
    }

    func testResetClearsState() {
        let sut = DecisionsListViewModel(activeServerRepository: MockActiveServerRepository())
        sut.processingExpireDecision = true
        sut.reset()
        XCTAssertFalse(sut.processingExpireDecision)
        if case .loading = sut.state { } else { XCTFail("Expected loading") }
        if case .loading = sut.stateByIP { } else { XCTFail("Expected loading") }
    }

    func testResetFiltersPanelToAppliedOnes() {
        let sut = DecisionsListViewModel(activeServerRepository: MockActiveServerRepository())
        sut.requestParams.filters = DecisionsRequestFilters(onlyActive: true, groupByIP: true)
        sut.filters = DecisionsRequestFilters(onlyActive: false, groupByIP: false)
        sut.resetFiltersPanelToAppliedOnes()
        XCTAssertEqual(sut.filters.onlyActive, sut.requestParams.filters.onlyActive)
        XCTAssertEqual(sut.filters.groupByIP, sut.requestParams.filters.groupByIP)
    }

    func testIsGroupedByIP() {
        let sut = DecisionsListViewModel(activeServerRepository: MockActiveServerRepository())
        sut.requestParams.filters.groupByIP = true
        XCTAssertTrue(sut.isGroupedByIP)
        sut.requestParams.filters.groupByIP = false
        XCTAssertFalse(sut.isGroupedByIP)
    }

    func testFetchNoServerIsNoOp() async {
        let sut = DecisionsListViewModel(activeServerRepository: MockActiveServerRepository())
        sut.requestParams.filters.groupByIP = false
        await sut.initialFetchDecisions()
        if case .loading = sut.state { } else { XCTFail("Expected loading") }
    }
}
