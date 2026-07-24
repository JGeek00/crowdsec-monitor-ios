@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class AllowlistsListViewModelAsyncTests: XCTestCase {
    func testFetchDataSuccess() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/allowlists"] = TestViewModelFactory.encode(
            AllowlistsListResponse(data: [], length: 0)
        )
        let sut = AllowlistsListViewModel(activeServerRepository: activeRepo)
        await sut.fetchData()
        if case .success = sut.state { } else { XCTFail("Expected success") }
    }

    func testFetchDataWithShowLoading() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/allowlists"] = TestViewModelFactory.encode(
            AllowlistsListResponse(data: [], length: 0)
        )
        let sut = AllowlistsListViewModel(activeServerRepository: activeRepo)
        await sut.fetchData(showLoading: true)
        if case .success = sut.state { } else { XCTFail("Expected success") }
    }

    func testFetchDataFailure() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/allowlists"] = HttpClientError.httpError(statusCode: 500)
        let sut = AllowlistsListViewModel(activeServerRepository: activeRepo)
        await sut.fetchData()
        if case .failure = sut.state { } else { XCTFail("Expected failure") }
    }

    func testFetchDataCancellationIsSwallowed() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/allowlists"] = CancellationError()
        let sut = AllowlistsListViewModel(activeServerRepository: activeRepo)
        sut.state = .success(AllowlistsListResponse(data: [], length: 0))
        await sut.fetchData()
        if case .success = sut.state { } else { XCTFail("Expected state unchanged") }
    }

    func testResetSetsLoading() async {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/allowlists"] = TestViewModelFactory.encode(
            AllowlistsListResponse(data: [], length: 0)
        )
        let sut = AllowlistsListViewModel(activeServerRepository: activeRepo)
        await sut.fetchData()
        sut.reset()
        if case .loading = sut.state { } else { XCTFail("Expected loading") }
    }

    func testFetchDataNoServerIsNoOp() async {
        let sut = AllowlistsListViewModel(activeServerRepository: MockActiveServerRepository())
        await sut.fetchData()
        if case .loading = sut.state { } else { XCTFail("Expected loading") }
    }
}
