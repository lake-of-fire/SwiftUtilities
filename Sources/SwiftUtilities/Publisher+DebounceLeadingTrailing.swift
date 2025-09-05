import Foundation
import Combine

public extension Publisher {
    @inlinable
    func debounceLeadingTrailing<S: Scheduler>(for interval: S.SchedulerTimeType.Stride, scheduler: S) -> AnyPublisher<Output, Failure> {
        let shared = share()
        return shared
            .throttle(for: interval, scheduler: scheduler, latest: false) // leading
            .merge(with: shared.debounce(for: interval, scheduler: scheduler)) // trailing
            .eraseToAnyPublisher()
    }
}
