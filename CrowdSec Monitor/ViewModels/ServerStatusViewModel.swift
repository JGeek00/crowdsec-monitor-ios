import SwiftUI

@MainActor
@Observable
class ServerStatusViewModel {
    public static let shared = ServerStatusViewModel()

    var state: Enums.LoadingState<APIStatusResponse> = .loading

    @ObservationIgnored private var streamTask: Task<Void, Never>?

    private init() {
        Task { await fetchStatus() }
    }

    func reset() {
        closeWebSocket()
        state = .loading
    }

    func fetchStatus() async {
        guard let apiClient = AuthViewModel.shared.apiClient else { return }
        state = .loading
        do {
            let response = try await apiClient.checkApiStatus()
            state = .success(response.body)
            openWebSocket()
        } catch {
            state = .failure(error)
        }
    }

    func openWebSocket() {
        guard streamTask == nil || streamTask?.isCancelled == true else { return }
        guard let apiClient = AuthViewModel.shared.apiClient else { return }

        streamTask = Task {
            do {
                for try await status in apiClient.streamApiStatus() {
                    state = .success(status)
                }
            } catch {
                if !Task.isCancelled {
                    state = .failure(error)
                }
            }
        }
    }

    func closeWebSocket() {
        streamTask?.cancel()
        streamTask = nil
        AuthViewModel.shared.apiClient?.disconnectApiStatusStream()
    }
}
