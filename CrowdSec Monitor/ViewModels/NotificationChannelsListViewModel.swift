import Foundation
import SwiftUI

@MainActor
@Observable
class NotificationChannelsListViewModel {

    @ObservationIgnored private let activeServerRepository: ActiveServerRepository

    init(activeServerRepository: ActiveServerRepository = RepositoriesContainer.shared.activeServerRepository) {
        self.activeServerRepository = activeServerRepository
        NotificationCenter.default.addObserver(forName: .serverDidChange, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.reset()
            }
        }
    }

    var state: Enums.LoadingState<[UserNotificationChannel]> = .loading
    var providers: [NotificationProvider] = []
    var errorDelete = false
    var channelInUse = false
    var didDelete = false

    func reset() {
        state = .loading
        errorDelete = false
        channelInUse = false
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
            let response = try await apiClient.notificationChannels.fetchChannels()
            withAnimation {
                state = .success(response.body.data)
            }
            do {
                let providersResponse = try await apiClient.notificationChannels.fetchProviders()
                providers = providersResponse.body.providers
            } catch {
                guard !(error is CancellationError) else { return }
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

    func delete(channelId: Int) async {
        guard let apiClient = activeServerRepository.apiClient else { return }
        do {
            _ = try await apiClient.notificationChannels.deleteChannel(channelId: channelId)
            if case .success(let items) = state {
                withAnimation {
                    state = .success(items.filter { $0.id != channelId })
                }
            }
            didDelete = true
        } catch {
            guard !(error is CancellationError) else { return }
            if isConflict(error) {
                channelInUse = true
            } else {
                errorDelete = true
            }
        }
    }

    private func isConflict(_ error: Error) -> Bool {
        if case HttpClientError.httpError(let statusCode) = error, statusCode == 409 {
            return true
        }
        if case HttpClientError.httpErrorWithMessage(let statusCode, _) = error, statusCode == 409 {
            return true
        }
        return false
    }
}
