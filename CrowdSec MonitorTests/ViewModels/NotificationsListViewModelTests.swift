@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class NotificationsListViewModelTests: XCTestCase {
    private func makeSUT() -> (NotificationsListViewModel, MockHttpClient) {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        return (NotificationsListViewModel(activeServerRepository: activeRepo), mockHttp)
    }

    private func makeNotification(id: Int = 1, enabled: Bool = true) -> UserNotification {
        UserNotification(
            id: id, name: "n\(id)", description: nil, enabled: enabled,
            condition: .leaf(field: "scenario", op: "equals", value: .single("x")),
            threshold: nil, message: "m", includeAlertInfo: false, channelIds: [1], createdAt: nil, updatedAt: nil
        )
    }

    func testStateLoadingByDefault() {
        let (sut, _) = makeSUT()
        if case .loading = sut.state {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected loading")
        }
    }

    func testFetchSuccess() async {
        let (sut, mockHttp) = makeSUT()
        mockHttp.stubbedResponsesByEndpoint["/api/v1/notifications"] = TestViewModelFactory.encode(
            NotificationsListResponse(data: [makeNotification()])
        )
        await sut.fetchData()
        if case .success(let items) = sut.state {
            XCTAssertEqual(items.count, 1)
        } else {
            XCTFail("Expected success")
        }
    }

    func testFetchFailure() async {
        let (sut, mockHttp) = makeSUT()
        mockHttp.stubbedErrorsByEndpoint["/api/v1/notifications"] = HttpClientError.httpError(statusCode: 500)
        await sut.fetchData()
        if case .failure = sut.state {
        } else {
            XCTFail("Expected failure")
        }
    }

    func testToggleUpdatesItem() async {
        let (sut, mockHttp) = makeSUT()
        sut.state = .success([makeNotification(enabled: true)])
        mockHttp.stubbedResponsesByEndpoint["/api/v1/notifications/1/enabled"] = TestViewModelFactory.encode(
            NotificationDetailResponse(data: makeNotification(enabled: false))
        )
        await sut.toggle(notification: makeNotification(enabled: true))
        if case .success(let items) = sut.state {
            XCTAssertFalse(items.first?.enabled ?? true)
        } else {
            XCTFail("Expected success")
        }
        XCTAssertFalse(sut.errorToggle)
    }

    func testToggleErrorFlag() async {
        let (sut, mockHttp) = makeSUT()
        sut.state = .success([makeNotification()])
        mockHttp.stubbedErrorsByEndpoint["/api/v1/notifications/1/enabled"] = HttpClientError.httpError(statusCode: 500)
        await sut.toggle(notification: makeNotification())
        XCTAssertTrue(sut.errorToggle)
    }

    func testDeleteRemovesItem() async {
        let (sut, mockHttp) = makeSUT()
        sut.state = .success([makeNotification(id: 1), makeNotification(id: 2)])
        mockHttp.stubbedResponsesByEndpoint["/api/v1/notifications/1"] = TestViewModelFactory.encode(
            DeleteNotificationResponse(message: "Notification deleted")
        )
        await sut.delete(notificationId: 1)
        if case .success(let items) = sut.state {
            XCTAssertEqual(items.map { $0.id }, [2])
        } else {
            XCTFail("Expected success")
        }
        XCTAssertTrue(sut.didDelete)
    }
}
