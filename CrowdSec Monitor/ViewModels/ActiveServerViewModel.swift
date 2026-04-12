import Foundation
import SwiftUI

@MainActor
@Observable
class ActiveServerViewModel {
    static let shared = ActiveServerViewModel()

    var currentServer: CSServer?
    var apiClient: CrowdSecAPIClient?

    var hasServerConfigured: Bool {
        currentServer != nil && apiClient != nil
    }

    // MARK: - Resettable registry

    @ObservationIgnored private var resettableViewModels: [WeakResettable] = []

    /// Register a ViewModel to be reset automatically on every server switch.
    func register(_ vm: any Resettable) {
        guard !resettableViewModels.contains(where: { $0.value === vm }) else { return }
        resettableViewModels.append(WeakResettable(vm))
    }

    // MARK: - Server-scoped tasks

    /// Active tasks spawned for the current server. All of them are cancelled when the server changes.
    @ObservationIgnored private var serverTasks: [UUID: Task<Void, Never>] = [:]

    /// Allows async requests to be automatically cancelled when switching server.
    /// When NOT to use this:
    /// - In `init()` of a singleton ViewModel
    /// - In non-singleton ViewModels (detail screens, forms)
    ///
    /// The `catch` block in `operation` should ignore `CancellationError`:
    /// ```swift
    /// } catch {
    ///     guard !(error is CancellationError) else { return }
    ///     state = .failure(error)
    /// }
    /// ```
    @discardableResult
    func task(_ operation: @escaping () async -> Void) -> Task<Void, Never> {
        let id = UUID()
        let t = Task { [weak self] in
            await operation()
            self?.serverTasks.removeValue(forKey: id)
        }
        serverTasks[id] = t
        return t
    }

    /// Switch to a new server, tearing down the previous connection first.
    func activate(_ server: CSServer) {
        apiClient?.invalidate()
        cancelAllServerTasks()
        currentServer = server
        apiClient = CrowdSecAPIClient(server)
        resetAllViewModels()
    }

    /// Remove the active server (e.g. the last server was deleted).
    func deactivate() {
        apiClient?.invalidate()
        cancelAllServerTasks()
        currentServer = nil
        apiClient = nil
        resetAllViewModels()
    }

    // MARK: - Error handling

    /// Called when a 401 is received. Delegates deletion to ServersManagerViewModel.
    func handleUnauthorized() {
        guard let server = currentServer else { return }
        ServersManagerViewModel.shared.deleteServer(server: server)
    }

    // MARK: - Private helpers

    private func cancelAllServerTasks() {
        serverTasks.values.forEach { $0.cancel() }
        serverTasks.removeAll()
    }

    private func resetAllViewModels() {
        resettableViewModels.removeAll { $0.value == nil }
        resettableViewModels.forEach { $0.value?.reset() }
    }

    private init() {}
}

// MARK: - Weak wrapper for Resettable

private struct WeakResettable {
    weak var value: (any Resettable)?
    init(_ value: any Resettable) { self.value = value }
}
