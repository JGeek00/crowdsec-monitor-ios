@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class NotificationChannelsListViewModelTests: XCTestCase {
    private func makeSUT() -> (NotificationChannelsListViewModel, MockHttpClient) {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        return (NotificationChannelsListViewModel(activeServerRepository: activeRepo), mockHttp)
    }

    private func makeChannel(id: Int = 1) -> UserNotificationChannel {
        UserNotificationChannel(
            id: id, name: "c\(id)", type: .email,
            config: NotificationChannelConfig(host: "h", from: "a@b.c", to: "d@e.f"),
            createdAt: nil, updatedAt: nil
        )
    }

    func testFetchSuccess() async {
        let (sut, mockHttp) = makeSUT()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/notification-channels"] = TestViewModelFactory.encode(
            NotificationChannelsListResponse(data: [makeChannel()])
        )
        await sut.fetchData()
        if case .success(let items) = sut.state {
            XCTAssertEqual(items.count, 1)
        } else {
            XCTFail("Expected success")
        }
    }

    func testDeleteRemovesItem() async {
        let (sut, mockHttp) = makeSUT()
        sut.state = .success([makeChannel(id: 1)])
        mockHttp.stubbedResponsesByEndpoint["/api/v1/notification-channels/1"] = TestViewModelFactory.encode(
            DeleteNotificationChannelResponse(message: "Channel deleted")
        )
        await sut.delete(channelId: 1)
        if case .success(let items) = sut.state {
            XCTAssertTrue(items.isEmpty)
        } else {
            XCTFail("Expected success")
        }
        XCTAssertTrue(sut.didDelete)
    }

    func testDeleteConflictSetsChannelInUse() async {
        let (sut, mockHttp) = makeSUT()
        sut.state = .success([makeChannel(id: 1)])
        mockHttp.stubbedErrorsByEndpoint["/api/v1/notification-channels/1"] = HttpClientError.httpErrorWithMessage(
            statusCode: 409, message: "Channel is used"
        )
        await sut.delete(channelId: 1)
        XCTAssertTrue(sut.channelInUse)
        XCTAssertFalse(sut.errorDelete)
        if case .success(let items) = sut.state {
            XCTAssertEqual(items.count, 1)
        } else {
            XCTFail("Expected items preserved")
        }
    }

    func testDeleteOtherErrorSetsErrorDelete() async {
        let (sut, mockHttp) = makeSUT()
        sut.state = .success([makeChannel(id: 1)])
        mockHttp.stubbedErrorsByEndpoint["/api/v1/notification-channels/1"] = HttpClientError.httpError(statusCode: 500)
        await sut.delete(channelId: 1)
        XCTAssertTrue(sut.errorDelete)
        XCTAssertFalse(sut.channelInUse)
    }
}
