import Foundation
import SwiftUI

@MainActor
@Observable
class NotificationsListViewModel {

    @ObservationIgnored private let activeServerRepository: ActiveServerRepository

    init(activeServerRepository: ActiveServerRepository = RepositoriesContainer.shared.activeServerRepository) {
        self.activeServerRepository = activeServerRepository
        NotificationCenter.default.addObserver(forName: .serverDidChange, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.reset()
            }
        }
    }

    var state: Enums.LoadingState<[UserNotification]> = .loading
    var errorToggle = false
    var errorDelete = false
    var didDelete = false

    func reset() {
        state = .loading
        errorToggle = false
        errorDelete = false
        didDelete = false
    }

    func fetchData(showLoading: Bool = false) async {
        guard let apiClient = activeServerRepository.apiClient else { return }
        do {
            if showLoading {
                withAnimation {
                    state = .loading
                }
            }
            let response = try await apiClient.notifications.fetchNotifications()
            withAnimation {
                state = .success(response.body.data)
            }
        } catch {
            guard !(error is CancellationError) else { return }
            withAnimation {
                state = .failure(error)
            }
        }
    }

    func initialFetch() async {
        if state.data == nil {
            await fetchData(showLoading: true)
        }
    }

    func refresh() async {
        await fetchData()
    }

    func toggle(notification: UserNotification) async {
        guard let apiClient = activeServerRepository.apiClient else { return }
        do {
            let body = ToggleNotificationRequest(enabled: !notification.enabled)
            let response = try await apiClient.notifications.toggleNotification(
                notificationId: notification.id, body: body
            )
            if case .success(let items) = state {
                withAnimation {
                    state = .success(items.map { $0.id == notification.id ? response.body.data : $0 })
                }
            }
        } catch {
            guard !(error is CancellationError) else { return }
            errorToggle = true
        }
    }

    func delete(notificationId: Int) async {
        guard let apiClient = activeServerRepository.apiClient else { return }
        do {
            _ = try await apiClient.notifications.deleteNotification(notificationId: notificationId)
            if case .success(let items) = state {
                withAnimation {
                    state = .success(items.filter { $0.id != notificationId })
                }
            }
            didDelete = true
        } catch {
            guard !(error is CancellationError) else { return }
            errorDelete = true
        }
    }
}
