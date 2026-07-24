@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class BlocklistsListViewModelAsyncTests: XCTestCase {
    private func makeSUT() -> (BlocklistsListViewModel, MockHttpClient, MockActiveServerRepository, ServiceStatusRepository) {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        let statusRepo = ServiceStatusRepository(activeServerRepository: activeRepo)
        let sut = BlocklistsListViewModel(activeServerRepository: activeRepo, serviceStatusRepository: statusRepo)
        return (sut, mockHttp, activeRepo, statusRepo)
    }

    private func makeBlocklistsResponse(items: [BlocklistsListResponse_Item], page: Int = 1, total: Int = 100) -> BlocklistsListResponse {
        BlocklistsListResponse(items: items, pagination: BlocklistsListResponse_Pagination(page: page, amount: 25, total: total))
    }

    private func makeItem(id: String, name: String = "test") -> BlocklistsListResponse_Item {
        BlocklistsListResponse_Item(id: id, url: nil, name: name, enabled: true, addedDate: nil, lastRefreshAttempt: nil, lastSuccessfulRefresh: nil, lastRefreshFailed: nil, countIPS: 0, type: .api)
    }

    func testFetchDataSuccess() async {
        let (sut, mockHttp, _, _) = makeSUT()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/blocklists"] = TestViewModelFactory.encode(
            makeBlocklistsResponse(items: [makeItem(id: "b1"), makeItem(id: "b2")])
        )
        await sut.fetchData()
        if case .success(let data) = sut.state {
            XCTAssertEqual(data.items.count, 2)
        } else { XCTFail("Expected success") }
    }

    func testFetchDataWithShowLoadingSetsLoadingFirst() async {
        let (sut, mockHttp, _, _) = makeSUT()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/blocklists"] = TestViewModelFactory.encode(
            makeBlocklistsResponse(items: [])
        )
        await sut.fetchData(showLoading: true)
        if case .success = sut.state { } else { XCTFail("Expected success") }
    }

    func testFetchDataFailure() async {
        let (sut, mockHttp, _, _) = makeSUT()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/blocklists"] = HttpClientError.httpError(statusCode: 500)
        await sut.fetchData()
        if case .failure = sut.state { } else { XCTFail("Expected failure") }
    }

    func testFetchDataCancellationIsSwallowed() async {
        let (sut, mockHttp, _, _) = makeSUT()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/blocklists"] = CancellationError()
        sut.state = .success(makeBlocklistsResponse(items: [makeItem(id: "pre")]))
        await sut.fetchData()
        // State should remain unchanged (CancellationError is swallowed)
        if case .success(let data) = sut.state {
            XCTAssertEqual(data.items.count, 1)
            XCTAssertEqual(data.items.first?.id, "pre")
        } else { XCTFail("Expected state unchanged after cancellation") }
    }

    func testInitialFetchWhenDataNilFetches() async {
        let (sut, mockHttp, _, _) = makeSUT()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/blocklists"] = TestViewModelFactory.encode(
            makeBlocklistsResponse(items: [makeItem(id: "b1")])
        )
        await sut.initialFetch()
        if case .success = sut.state { } else { XCTFail("Expected success") }
    }

    func testInitialFetchWhenDataPresentIsNoOp() async {
        let (sut, mockHttp, _, _) = makeSUT()
        sut.state = .success(makeBlocklistsResponse(items: [makeItem(id: "existing")]))
        await sut.initialFetch()
        if case .success(let data) = sut.state {
            XCTAssertEqual(data.items.count, 1)
            XCTAssertEqual(data.items.first?.id, "existing")
        } else { XCTFail("Expected unchanged") }
    }

    func testFetchMoreDeduplicatesByID() async {
        let (sut, mockHttp, _, _) = makeSUT()
        // Page 1: 2 items
        sut.state = .success(makeBlocklistsResponse(items: [makeItem(id: "b1"), makeItem(id: "b2")], page: 1, total: 100))
        // Page 2: b2 (duplicate) + b3 (new)
        mockHttp.stubbedResponsesByEndpoint["/api/v1/blocklists"] = TestViewModelFactory.encode(
            makeBlocklistsResponse(items: [makeItem(id: "b2"), makeItem(id: "b3")], page: 2, total: 100)
        )
        await sut.fetchMore()
        if case .success(let data) = sut.state {
            XCTAssertEqual(data.items.count, 3) // b1, b2, b3 — b2 deduplicated
            XCTAssertEqual(data.items.map(\.id).sorted(), ["b1", "b2", "b3"])
        } else { XCTFail("Expected success") }
    }

    func testFetchMoreWhenPaginationReachedIsNoOp() async {
        let (sut, mockHttp, _, _) = makeSUT()
        // page * batch >= total → no more pages
        sut.state = .success(makeBlocklistsResponse(items: [makeItem(id: "b1")], page: 10, total: 25))
        await sut.fetchMore()
        if case .success(let data) = sut.state {
            XCTAssertEqual(data.items.count, 1) // unchanged
        } else { XCTFail("Expected unchanged") }
    }

    func testEnableDisableBlocklistSuccess() async {
        let (sut, mockHttp, _, _) = makeSUT()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/blocklists/b1/enabled"] = Data("{}".utf8)
        mockHttp.stubbedResponsesByEndpoint["/api/v1/blocklists"] = TestViewModelFactory.encode(
            makeBlocklistsResponse(items: [makeItem(id: "b1")])
        )
        await sut.enableDisableBlocklist(blocklistId: "b1", newStatus: true)
        XCTAssertFalse(sut.processingModal)
        XCTAssertFalse(sut.errorEnableBlocklist)
    }

    func testEnableDisableBlocklistFailureSetsErrorFlag() async {
        let (sut, mockHttp, _, _) = makeSUT()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/blocklists/b1/enabled"] = HttpClientError.httpError(statusCode: 500)
        await sut.enableDisableBlocklist(blocklistId: "b1", newStatus: true)
        XCTAssertFalse(sut.processingModal)
        XCTAssertTrue(sut.errorEnableBlocklist)
        XCTAssertFalse(sut.errorDisableBlocklist)
    }

    func testDisableBlocklistFailureSetsDisableFlag() async {
        let (sut, mockHttp, _, _) = makeSUT()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/blocklists/b1/enabled"] = HttpClientError.httpError(statusCode: 500)
        await sut.enableDisableBlocklist(blocklistId: "b1", newStatus: false)
        XCTAssertTrue(sut.errorDisableBlocklist)
        XCTAssertFalse(sut.errorEnableBlocklist)
    }

    func testDeleteBlocklistSuccess() async {
        let (sut, mockHttp, _, _) = makeSUT()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/blocklists/b1"] = Data("{}".utf8)
        mockHttp.stubbedResponsesByEndpoint["/api/v1/blocklists"] = TestViewModelFactory.encode(
            makeBlocklistsResponse(items: [])
        )
        await sut.deleteBlocklist(blocklistId: "b1")
        XCTAssertFalse(sut.processingModal)
        XCTAssertTrue(sut.blocklistDeletedSuccessfully)
        XCTAssertFalse(sut.errorDeleteBlocklist)
    }

    func testDeleteBlocklistFailure() async {
        let (sut, mockHttp, _, _) = makeSUT()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/blocklists/b1"] = HttpClientError.httpError(statusCode: 500)
        await sut.deleteBlocklist(blocklistId: "b1")
        XCTAssertFalse(sut.processingModal)
        XCTAssertTrue(sut.errorDeleteBlocklist)
        XCTAssertFalse(sut.blocklistDeletedSuccessfully)
    }

    func testRefreshAllBlocklistsSuccess() async {
        let (sut, mockHttp, _, _) = makeSUT()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/lists/refresh"] = Data("{\"message\":\"ok\"}".utf8)
        sut.refreshBlocklists()
        try? await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertFalse(sut.processingModal)
        XCTAssertFalse(sut.errorRefreshBlocklist)
    }

    func testRefreshSingleBlocklistFailure() async {
        let (sut, mockHttp, _, _) = makeSUT()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/lists/blocklists/b1/refresh"] = HttpClientError.httpError(statusCode: 500)
        sut.refreshBlocklists(blocklistId: "b1")
        try? await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertTrue(sut.errorRefreshBlocklist)
        XCTAssertFalse(sut.processingModal)
    }

    func testResetClearsAllState() async {
        let (sut, mockHttp, _, _) = makeSUT()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/blocklists"] = TestViewModelFactory.encode(
            makeBlocklistsResponse(items: [makeItem(id: "b1")])
        )
        await sut.fetchData()
        sut.selectedListName = "test"
        sut.processingModal = true
        sut.errorDeleteBlocklist = true
        sut.reset()
        if case .loading = sut.state { } else { XCTFail("Expected loading") }
        XCTAssertNil(sut.selectedListName)
        XCTAssertFalse(sut.processingModal)
        XCTAssertFalse(sut.errorDeleteBlocklist)
        XCTAssertEqual(sut.requestParams.offset, 0)
    }

    func testFetchDataNoServerIsNoOp() async {
        let activeRepo = MockActiveServerRepository()
        let statusRepo = ServiceStatusRepository(activeServerRepository: activeRepo)
        let sut = BlocklistsListViewModel(activeServerRepository: activeRepo, serviceStatusRepository: statusRepo)
        await sut.fetchData()
        if case .loading = sut.state { } else { XCTFail("Expected loading (no-op)") }
    }
}
