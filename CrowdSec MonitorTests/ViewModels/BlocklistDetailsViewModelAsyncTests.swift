@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class BlocklistDetailsViewModelAsyncTests: XCTestCase {
    private func makeBlocklistData(id: String = "b1") -> BlocklistDataResponse {
        BlocklistDataResponse(data: BlocklistDataResponse_Data(
            id: id, url: nil, name: "test", enabled: true,
            addedDate: nil, lastRefreshAttempt: nil, lastSuccessfulRefresh: nil,
            lastRefreshFailed: nil, countIPS: 0, type: .api, blocklistIPS: []
        ))
    }

    func testFetchDataSuccess() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/blocklists/b1"] = TestViewModelFactory.encode(makeBlocklistData())
        let sut = BlocklistDetailsViewModel(blocklistId: "b1", activeServerRepository: activeRepo, serviceStatusRepository: ServiceStatusRepository(activeServerRepository: activeRepo))
        await sut.fetchData()
        if case .success(let data) = sut.status {
            XCTAssertEqual(data.data.id, "b1")
        } else { XCTFail("Expected success") }
    }

    func testFetchDataFailure() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/blocklists/b1"] = HttpClientError.httpError(statusCode: 500)
        let sut = BlocklistDetailsViewModel(blocklistId: "b1", activeServerRepository: activeRepo, serviceStatusRepository: ServiceStatusRepository(activeServerRepository: activeRepo))
        await sut.fetchData()
        if case .failure = sut.status { } else { XCTFail("Expected failure") }
    }

    func testEnableDisableBlocklistSuccess() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/blocklists/b1/enabled"] = Data("{}".utf8)
        mockHttp.stubbedResponsesByEndpoint["/api/v1/blocklists/b1"] = TestViewModelFactory.encode(makeBlocklistData())
        let sut = BlocklistDetailsViewModel(blocklistId: "b1", activeServerRepository: activeRepo, serviceStatusRepository: ServiceStatusRepository(activeServerRepository: activeRepo))
        await sut.enableDisableBlocklist(newStatus: true)
        XCTAssertFalse(sut.processingModal)
        XCTAssertFalse(sut.errorEnableBlocklist)
    }

    func testEnableDisableBlocklistFailure() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/blocklists/b1/enabled"] = HttpClientError.httpError(statusCode: 500)
        let sut = BlocklistDetailsViewModel(blocklistId: "b1", activeServerRepository: activeRepo, serviceStatusRepository: ServiceStatusRepository(activeServerRepository: activeRepo))
        await sut.enableDisableBlocklist(newStatus: true)
        XCTAssertTrue(sut.errorEnableBlocklist)
        XCTAssertFalse(sut.processingModal)
    }

    func testDeleteBlocklistSuccess() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/blocklists/b1"] = Data("{}".utf8)
        let sut = BlocklistDetailsViewModel(blocklistId: "b1", activeServerRepository: activeRepo, serviceStatusRepository: ServiceStatusRepository(activeServerRepository: activeRepo))
        await sut.deleteBlocklist()
        XCTAssertTrue(sut.blocklistDeletedSuccessfully)
        XCTAssertFalse(sut.processingModal)
    }

    func testDeleteBlocklistFailure() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/blocklists/b1"] = HttpClientError.httpError(statusCode: 500)
        let sut = BlocklistDetailsViewModel(blocklistId: "b1", activeServerRepository: activeRepo, serviceStatusRepository: ServiceStatusRepository(activeServerRepository: activeRepo))
        await sut.deleteBlocklist()
        XCTAssertTrue(sut.errorDeleteBlocklist)
        XCTAssertFalse(sut.blocklistDeletedSuccessfully)
    }

    func testRefreshBlocklistSuccess() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/lists/blocklists/b1/refresh"] = Data("{\"message\":\"ok\"}".utf8)
        mockHttp.stubbedResponsesByEndpoint["/api/v1/blocklists/b1"] = TestViewModelFactory.encode(makeBlocklistData())
        let sut = BlocklistDetailsViewModel(blocklistId: "b1", activeServerRepository: activeRepo, serviceStatusRepository: ServiceStatusRepository(activeServerRepository: activeRepo))
        sut.refreshBlocklist()
        try? await Task.sleep(nanoseconds: 400_000_000)
        XCTAssertFalse(sut.processingModal)
        XCTAssertFalse(sut.errorRefreshBlocklist)
    }

    func testRefreshBlocklistFailure() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/lists/blocklists/b1/refresh"] = HttpClientError.httpError(statusCode: 500)
        let sut = BlocklistDetailsViewModel(blocklistId: "b1", activeServerRepository: activeRepo, serviceStatusRepository: ServiceStatusRepository(activeServerRepository: activeRepo))
        sut.refreshBlocklist()
        try? await Task.sleep(nanoseconds: 400_000_000)
        XCTAssertTrue(sut.errorRefreshBlocklist)
        XCTAssertFalse(sut.processingModal)
    }

    func testUpdateBlocklistIdChangesId() {
        let (_, _, activeRepo) = TestViewModelFactory.makeStack()
        let sut = BlocklistDetailsViewModel(blocklistId: "b1", activeServerRepository: activeRepo, serviceStatusRepository: ServiceStatusRepository(activeServerRepository: activeRepo))
        sut.updateBlocklistId("b2")
        XCTAssertEqual(sut.blocklistId, "b2")
        XCTAssertEqual(sut.ipsRound, 1)
    }

    func testIncrementIpsRound() {
        let (_, _, activeRepo) = TestViewModelFactory.makeStack()
        let sut = BlocklistDetailsViewModel(blocklistId: "b1", activeServerRepository: activeRepo, serviceStatusRepository: ServiceStatusRepository(activeServerRepository: activeRepo))
        let initial = sut.ipsRound
        sut.incrementIpsRound()
        XCTAssertEqual(sut.ipsRound, initial + 1)
    }

    func testFetchDataNoServerIsNoOp() async {
        let activeRepo = MockActiveServerRepository()
        let sut = BlocklistDetailsViewModel(blocklistId: "b1", activeServerRepository: activeRepo, serviceStatusRepository: ServiceStatusRepository(activeServerRepository: activeRepo))
        await sut.fetchData()
        if case .loading = sut.status { } else { XCTFail("Expected loading") }
    }
}
