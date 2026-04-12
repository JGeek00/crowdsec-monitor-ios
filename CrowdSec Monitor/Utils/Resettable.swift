import Foundation

// MARK: - Resettable

/// A ViewModel that can be reset to its initial state when the active server changes.
/// Conforming types must be registered with `ActiveServerViewModel` so they are reset
/// automatically on every server switch, without needing a hard-coded list.
///
/// Usage:
///   1. Conform your singleton ViewModel to `Resettable`.
///   2. Call `ActiveServerViewModel.shared.register(self)` inside `init()`.
///   3. Implement `reset()` to clear state and cancel any in-flight tasks.
@MainActor
protocol Resettable: AnyObject {
    /// Clears all loaded data, cancels in-flight network tasks, and returns
    /// the receiver to its initial `.loading` state.
    func reset()
}
