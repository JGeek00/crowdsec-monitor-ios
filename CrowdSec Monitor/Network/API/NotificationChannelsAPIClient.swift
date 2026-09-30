import Foundation

class NotificationChannelsAPIClient {
    private let httpClient: HttpClient

    init(_ httpClient: HttpClient) {
        self.httpClient = httpClient
    }

    func fetchChannels() async throws -> HttpResponse<NotificationChannelsListResponse> {
        return try await httpClient.get(endpoint: "/api/v1/notification-channels")
    }

    func createChannel(body: CreateChannelRequest) async throws -> HttpResponse<NotificationChannelDetailResponse> {
        return try await httpClient.post(endpoint: "/api/v1/notification-channels", body: body)
    }

    func fetchChannel(channelId: Int) async throws -> HttpResponse<NotificationChannelDetailResponse> {
        return try await httpClient.get(endpoint: "/api/v1/notification-channels/\(channelId)")
    }

    func updateChannel(channelId: Int, body: UpdateChannelRequest) async throws -> HttpResponse<NotificationChannelDetailResponse> {
        return try await httpClient.put(endpoint: "/api/v1/notification-channels/\(channelId)", body: body)
    }

    func deleteChannel(channelId: Int) async throws -> HttpResponse<DeleteNotificationChannelResponse> {
        return try await httpClient.delete(endpoint: "/api/v1/notification-channels/\(channelId)")
    }

    func testChannel(channelId: Int, body: TestChannelRequest) async throws -> HttpResponse<ChannelTestResponse> {
        return try await httpClient.post(endpoint: "/api/v1/notification-channels/\(channelId)/test", body: body)
    }

    func testInlineChannel(body: TestInlineChannelRequest) async throws -> HttpResponse<ChannelTestResponse> {
        return try await httpClient.post(endpoint: "/api/v1/notification-channels/test", body: body)
    }
}
