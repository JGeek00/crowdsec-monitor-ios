@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class NotificationsAPIClientTests: XCTestCase {
    private var mockHttp: MockHttpClient!

    override func setUp() {
        super.setUp()
        mockHttp = MockHttpClient()
    }

    override func tearDown() {
        mockHttp = nil
        super.tearDown()
    }

    private func makeClient() -> NotificationsAPIClient {
        NotificationsAPIClient(mockHttp)
    }

    private var notificationJSON: [String: Any] {
        [
            "id": 1,
            "name": "ssh alerts",
            "description": NSNull(),
            "enabled": true,
            "condition": [
                "type": "leaf", "field": "scenario",
                "operator": "equals", "value": "crowdsecurity/ssh-bf",
            ],
            "threshold": NSNull(),
            "message": "SSH detected",
            "includeAlertInfo": true,
            "channelIds": [2],
        ]
    }

    func testFetchNotifications() async throws {
        mockHttp.stubbedResponseData = try JSONSerialization.data(withJSONObject: ["data": [notificationJSON]])
        let response: HttpResponse<NotificationsListResponse> = try await makeClient().fetchNotifications()
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/notifications")
        XCTAssertEqual(response.body.data.count, 1)
        XCTAssertEqual(response.body.data.first?.name, "ssh alerts")
    }

    func testCreateNotification() async throws {
        mockHttp.stubbedResponseData = try JSONSerialization.data(withJSONObject: ["data": notificationJSON])
        let body = CreateNotificationRequest(
            name: "n", description: nil, enabled: true,
            condition: .leaf(field: "scenario", op: "equals", value: .single("x")),
            threshold: nil, message: "m", includeAlertInfo: false, channelIds: [2]
        )
        let _: HttpResponse<NotificationDetailResponse> = try await makeClient().createNotification(body: body)
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/notifications")
    }

    func testFetchNotification() async throws {
        mockHttp.stubbedResponseData = try JSONSerialization.data(withJSONObject: ["data": notificationJSON])
        let _: HttpResponse<NotificationDetailResponse> = try await makeClient().fetchNotification(notificationId: 7)
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/notifications/7")
    }

    func testUpdateNotification() async throws {
        mockHttp.stubbedResponseData = try JSONSerialization.data(withJSONObject: ["data": notificationJSON])
        let _: HttpResponse<NotificationDetailResponse> = try await makeClient().updateNotification(
            notificationId: 7, body: UpdateNotificationRequest(name: "renamed")
        )
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/notifications/7")
    }

    func testDeleteNotification() async throws {
        mockHttp.stubbedResponseData = Data("{\"message\":\"Notification deleted\"}".utf8)
        let _: HttpResponse<DeleteNotificationResponse> = try await makeClient().deleteNotification(notificationId: 7)
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/notifications/7")
    }

    func testToggleNotification() async throws {
        mockHttp.stubbedResponseData = try JSONSerialization.data(withJSONObject: ["data": notificationJSON])
        let _: HttpResponse<NotificationDetailResponse> = try await makeClient().toggleNotification(
            notificationId: 7, body: ToggleNotificationRequest(enabled: false)
        )
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/notifications/7/enabled")
    }

    func testFetchHistory() async throws {
        mockHttp.stubbedResponseData = try JSONSerialization.data(withJSONObject: [
            "data": [[
                "id": "h1", "notificationId": 1, "notificationName": "n",
                "message": "m", "triggeredAt": "2026-09-30T12:00:00Z",
                "channels": [["type": "email", "ok": true]],
            ]],
            "total": 1,
        ])
        let response: HttpResponse<NotificationHistoryResponse> = try await makeClient().fetchHistory()
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/notifications/history")
        XCTAssertEqual(response.body.total, 1)
        XCTAssertEqual(response.body.data.first?.channels.first?.type, "email")
    }

    func testConditionTreeRoundTrip() throws {
        let node = NotificationConditionNode.and([
            .or([
                .leaf(field: "scenario", op: "equals", value: .single("a")),
                .leaf(field: "scenario", op: "equals", value: .single("b")),
            ]),
            .leaf(field: "country", op: "in", value: .multiple(["ES", "FR"])),
        ])
        let data = try JSONEncoder().encode(node)
        let decoded = try JSONDecoder().decode(NotificationConditionNode.self, from: data)
        XCTAssertEqual(decoded, node)
    }
}
