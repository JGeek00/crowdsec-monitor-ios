import Foundation

class NotificationsAPIClient {
    private let httpClient: HttpClient

    init(_ httpClient: HttpClient) {
        self.httpClient = httpClient
    }

    func fetchNotifications() async throws -> HttpResponse<NotificationsListResponse> {
        return try await httpClient.get(endpoint: "/api/v1/notifications")
    }

    func createNotification(body: CreateNotificationRequest) async throws -> HttpResponse<NotificationDetailResponse> {
        return try await httpClient.post(endpoint: "/api/v1/notifications", body: body)
    }

    func fetchNotification(notificationId: Int) async throws -> HttpResponse<NotificationDetailResponse> {
        return try await httpClient.get(endpoint: "/api/v1/notifications/\(notificationId)")
    }

    func updateNotification(notificationId: Int, body: UpdateNotificationRequest) async throws -> HttpResponse<NotificationDetailResponse> {
        return try await httpClient.put(endpoint: "/api/v1/notifications/\(notificationId)", body: body)
    }

    func deleteNotification(notificationId: Int) async throws -> HttpResponse<DeleteNotificationResponse> {
        return try await httpClient.delete(endpoint: "/api/v1/notifications/\(notificationId)")
    }

    func toggleNotification(notificationId: Int, body: ToggleNotificationRequest) async throws -> HttpResponse<NotificationDetailResponse> {
        return try await httpClient.post(endpoint: "/api/v1/notifications/\(notificationId)/enabled", body: body)
    }

    func fetchHistory() async throws -> HttpResponse<NotificationHistoryResponse> {
        return try await httpClient.get(endpoint: "/api/v1/notifications/history")
    }
}
