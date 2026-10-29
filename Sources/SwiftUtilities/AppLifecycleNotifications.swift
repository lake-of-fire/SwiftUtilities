import Foundation

/// Publication is shared across executors; component work stays actor-owned.
/// A newer event can be published after a MainActor probe but before the
/// receiving actor resumes. Recheck this signal synchronously at admission.
/// Equivalent pending events do not revoke each other: cancellation of a
/// duplicate must not strand an earlier, still valid activation or pause.
fileprivate final class AppLifecycleNotificationOrder: @unchecked Sendable {
    private let lock = NSLock()
    private var generation: UInt64 = 0
    private var phase: AppLifecycleNotification.Phase?

    func next(for phase: AppLifecycleNotification.Phase) -> UInt64 {
        lock.withLock {
            generation &+= 1
            self.phase = phase
            return generation
        }
    }

    func matches(_ phase: AppLifecycleNotification.Phase) -> Bool {
        lock.withLock { self.phase == phase }
    }
}

/// A validated lifecycle notification that can cross an actor boundary.
/// Its state probe stays live because delivery can be delayed by an actor hop.
public struct AppLifecycleNotification: Sendable {
    public enum Phase: Equatable, Sendable {
        case active
        case background
    }

    public let phase: Phase
    fileprivate let generation: UInt64
    fileprivate let order: AppLifecycleNotificationOrder
    private let matchesCurrentState: @MainActor @Sendable () -> Bool

    fileprivate init(
        phase: Phase,
        generation: UInt64,
        order: AppLifecycleNotificationOrder,
        matchesCurrentState: @escaping @MainActor @Sendable () -> Bool
    ) {
        self.phase = phase
        self.generation = generation
        self.order = order
        self.matchesCurrentState = matchesCurrentState
    }

    @MainActor
    public func isCurrent() -> Bool {
        !Task.isCancelled && matchesCurrentState() && order.matches(phase)
    }
}

/// Keep one source on MainActor and one admission value on the work's actor.
/// Rejected notifications do not advance the order of accepted transitions.
@MainActor
public final class AppLifecycleNotificationSource {
    private let order = AppLifecycleNotificationOrder()

    public nonisolated init() {}

    public func notification(
        for phase: AppLifecycleNotification.Phase,
        isCurrent: @escaping @MainActor @Sendable () -> Bool
    ) -> AppLifecycleNotification? {
        guard !Task.isCancelled, isCurrent() else { return nil }
        return AppLifecycleNotification(
            phase: phase,
            generation: order.next(for: phase),
            order: order,
            matchesCurrentState: isCurrent
        )
    }
}

/// Mutate only on the component's owning actor, immediately after awaiting
/// `notification.isCurrent()`. Acceptance and closing work admission must not
/// be separated by another suspension point. This does not cancel or drain work.
public struct AppLifecycleNotificationAdmission: Sendable {
    private var appliedGeneration: UInt64 = 0

    public init() {}

    public mutating func accept(_ notification: AppLifecycleNotification) -> Bool {
        guard !Task.isCancelled,
              notification.order.matches(notification.phase),
              notification.generation > appliedGeneration else { return false }
        appliedGeneration = notification.generation
        return true
    }
}
