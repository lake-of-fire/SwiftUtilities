import Foundation
import Combine

public extension Publisher {
    @inlinable
    func debounceLeadingTrailing<S: Scheduler>(_ interval: S.SchedulerTimeType.Stride, on scheduler: S) -> AnyPublisher<Output, Failure> {
        let shared = share()
        return shared
            .throttle(for: interval, scheduler: scheduler, latest: false) // leading
            .merge(with: shared.debounce(for: interval, scheduler: scheduler)) // trailing
            .eraseToAnyPublisher()
    }
}

public extension Publisher where Output: Equatable {
    @inlinable
    func debounceLeadingTrailing<S: Scheduler>(_ interval: S.SchedulerTimeType.Stride, on scheduler: S, removingDuplicates: Bool) -> AnyPublisher<Output, Failure> {
        let base = debounceLeadingTrailing(interval, on: scheduler)
        return removingDuplicates ? base.removeDuplicates().eraseToAnyPublisher() : base
    }
}
