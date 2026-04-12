import SwiftUI

@MainActor
@Observable
class ServiceStatusViewModel: Resettable {
    public static let shared = ServiceStatusViewModel()

    var state: Enums.LoadingState<APIStatusResponse> = .loading

    @ObservationIgnored private var streamTask: Task<Void, Never>?

    private init() {
        ActiveServerViewModel.shared.register(self)
        Task { await fetchStatus() }
    }

    func fetchStatus() async {
        guard let apiClient = ActiveServerViewModel.shared.apiClient else { return }
        state = .loading
        do {
            let response = try await apiClient.checkApiStatus()
            state = .success(response.body)
            openWebSocket(apiClient: apiClient)
        } catch {
            guard !(error is CancellationError) else { return }
            state = .failure(error)
        }
    }

    func openWebSocket() {
        guard let apiClient = ActiveServerViewModel.shared.apiClient else { return }
        openWebSocket(apiClient: apiClient)
    }

    private func openWebSocket(apiClient: CrowdSecAPIClient) {
        guard streamTask == nil || streamTask?.isCancelled == true else { return }

        streamTask = Task {
            do {
                for try await status in apiClient.streamApiStatus() {
                    state = .success(status)
                }
            } catch {
                guard !(error is CancellationError) else { return }
                state = .failure(error)
            }
        }
    }

    func closeWebSocket() {
        streamTask?.cancel()
        streamTask = nil
    }

    func reset() {
        closeWebSocket()
        guard let apiClient = ActiveServerViewModel.shared.apiClient else {
            state = .loading
            return
        }
        state = .loading
        streamTask = Task {
            do {
                let response = try await apiClient.checkApiStatus()
                state = .success(response.body)
                openWebSocket(apiClient: apiClient)
            } catch {
                guard !(error is CancellationError) else { return }
                state = .failure(error)
            }
        }
    }
}
