import Foundation
import SwiftUI

@Observable
class ServiceStatusRepository {
    var state: Enums.LoadingState<APIStatusResponse> = .loading

    @ObservationIgnored nonisolated(unsafe) private var webSocketTask: Task<Void, Never>?
    @ObservationIgnored nonisolated(unsafe) private var serverChangeObserver: NSObjectProtocol?

    @ObservationIgnored private let activeServerRepository: ActiveServerRepository

    private func fetchStatus() async {
        guard let apiClient = activeServerRepository.apiClient else { return }
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
        guard let apiClient = activeServerRepository.apiClient else { return }
        openWebSocket(apiClient: apiClient)
    }

    private func openWebSocket(apiClient: CrowdSecAPIClient) {
        guard webSocketTask == nil || webSocketTask?.isCancelled == true else { return }

        webSocketTask = Task { [weak self] in
            do {
                for try await status in apiClient.streamApiStatus() {
                    self?.state = .success(status)
                }
            } catch {
                guard !(error is CancellationError) else { return }
                self?.state = .failure(error)
            }
        }
    }

    nonisolated func closeWebSocket() {
        webSocketTask?.cancel()
        webSocketTask = nil
    }

    /// Closes the old WebSocket, fetches fresh status via HTTP, and opens a new WebSocket on success.
    func reconnect() {
        closeWebSocket()
        guard let apiClient = activeServerRepository.apiClient else {
            state = .loading
            return
        }
        state = .loading
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let response = try await apiClient.checkApiStatus()
                self.state = .success(response.body)
                self.openWebSocket(apiClient: apiClient)
            } catch {
                guard !(error is CancellationError) else { return }
                self.state = .failure(error)
            }
        }
    }

    private func resetOnServerChange() {
        reconnect()
    }

    init(activeServerRepository: ActiveServerRepository) {
        self.activeServerRepository = activeServerRepository
        serverChangeObserver = NotificationCenter.default.addObserver(
            forName: .serverDidChange, object: nil, queue: .main
        ) { [weak self] _ in
            self?.resetOnServerChange()
        }
        Task { [weak self] in
            await self?.fetchStatus()
        }
    }

    deinit {
        closeWebSocket()
        if let observer = serverChangeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
