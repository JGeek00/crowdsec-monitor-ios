@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class NotificationChannelsAPIClientTests: XCTestCase {
    private var mockHttp: MockHttpClient!

    override func setUp() {
        super.setUp()
        mockHttp = MockHttpClient()
    }

    override func tearDown() {
        mockHttp = nil
        super.tearDown()
    }

    private func makeClient() -> NotificationChannelsAPIClient {
        NotificationChannelsAPIClient(mockHttp)
    }

    private var channelJSON: [String: Any] {
        [
            "id": 3,
            "name": "ops email",
            "type": "email",
            "config": ["host": "smtp.example.com", "from": "a@b.c", "to": "d@e.f"],
        ]
    }

    func testFetchProviders() async throws {
        mockHttp.stubbedResponseData = try JSONSerialization.data(withJSONObject: [
            "version": 1,
            "providers": [[
                "type": "ntfy", "icon": "ntfy", "labelKey": "provider_ntfy",
                "supportsTest": true,
                "fields": [["key": "topic", "labelKey": "field_topic", "type": "text", "required": true]],
            ]],
        ])
        let response: HttpResponse<ProvidersListResponse> = try await makeClient().fetchProviders()
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/notification-channels/providers")
        XCTAssertEqual(response.body.providers.first?.fields.first?.key, "topic")
    }

    func testFetchChannels() async throws {
        mockHttp.stubbedResponseData = try JSONSerialization.data(withJSONObject: ["data": [channelJSON]])
        let response: HttpResponse<NotificationChannelsListResponse> = try await makeClient().fetchChannels()
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/notification-channels")
        XCTAssertEqual(response.body.data.first?.type, .email)
    }

    func testCreateChannel() async throws {
        mockHttp.stubbedResponseData = try JSONSerialization.data(withJSONObject: ["data": channelJSON])
        let body = CreateChannelRequest(name: "c", type: "ntfy", config: ["topic": .string("t")])
        let _: HttpResponse<NotificationChannelDetailResponse> = try await makeClient().createChannel(body: body)
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/notification-channels")
    }

    func testFetchChannel() async throws {
        mockHttp.stubbedResponseData = try JSONSerialization.data(withJSONObject: ["data": channelJSON])
        let _: HttpResponse<NotificationChannelDetailResponse> = try await makeClient().fetchChannel(channelId: 3)
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/notification-channels/3")
    }

    func testUpdateChannel() async throws {
        mockHttp.stubbedResponseData = try JSONSerialization.data(withJSONObject: ["data": channelJSON])
        let _: HttpResponse<NotificationChannelDetailResponse> = try await makeClient().updateChannel(
            channelId: 3, body: UpdateChannelRequest(name: "renamed")
        )
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/notification-channels/3")
    }

    func testDeleteChannel() async throws {
        mockHttp.stubbedResponseData = Data("{\"message\":\"Channel deleted\"}".utf8)
        let _: HttpResponse<DeleteNotificationChannelResponse> = try await makeClient().deleteChannel(channelId: 3)
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/notification-channels/3")
    }

    func testTestChannel() async throws {
        mockHttp.stubbedResponseData = Data("{\"data\":{\"channelId\":3,\"ok\":true,\"detail\":null}}".utf8)
        let response: HttpResponse<ChannelTestResponse> = try await makeClient().testChannel(
            channelId: 3, body: TestChannelRequest(message: "ping")
        )
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/notification-channels/3/test")
        XCTAssertTrue(response.body.data.ok)
    }

    func testTestInlineChannel() async throws {
        mockHttp.stubbedResponseData = Data("{\"data\":{\"channelId\":null,\"ok\":false,\"detail\":\"boom\"}}".utf8)
        let response: HttpResponse<ChannelTestResponse> = try await makeClient().testInlineChannel(
            body: TestInlineChannelRequest(type: "ntfy", config: ["topic": .string("t")], message: nil)
        )
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/notification-channels/test")
        XCTAssertNil(response.body.data.channelId)
        XCTAssertFalse(response.body.data.ok)
    }
}
