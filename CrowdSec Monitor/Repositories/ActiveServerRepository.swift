import Foundation
import SwiftUI

@Observable
class ActiveServerRepository {
    var currentServer: CSServer?
    var apiClient: CrowdSecAPIClient?

    var hasServerConfigured: Bool {
        currentServer != nil && apiClient != nil
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
        NotificationCenter.default.post(name: .serverDidChange, object: nil)
    }

    /// Remove the active server (e.g. the last server was deleted).
    func deactivate() {
        apiClient?.invalidate()
        cancelAllServerTasks()
        currentServer = nil
        apiClient = nil
        NotificationCenter.default.post(name: .serverDidChange, object: nil)
    }

    // MARK: - Private helpers

    private func cancelAllServerTasks() {
        serverTasks.values.forEach { $0.cancel() }
        serverTasks.removeAll()
    }

    init() {}
}
