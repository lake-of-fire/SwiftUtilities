import Foundation
import Combine

public extension Publisher {
    /// Leading + conditional trailing:
    /// - Emits the first value immediately (leading)
    /// - Starts a quiet window of `interval`
    /// - Emits the last value at the end of the quiet window (trailing) only if at least
    ///   one more value arrived after the leading within that window.
    /// - If only a single value occurs in a burst, no trailing is emitted.
    @inlinable
    func debounceLeadingTrailing<S: Scheduler>(
        for interval: S.SchedulerTimeType.Stride,
        scheduler: S
    ) -> AnyPublisher<Output, Failure> {
        let shared = self.share()

        let annotated = shared
            .map { (value: $0, time: scheduler.now) }
            .scan(
                (
                    lastTime: Optional<S.SchedulerTimeType>.none,
                    burstID: 0,
                    indexInBurst: 0,
                    value: Optional<Output>.none
                )
            ) { state, input in
                var burstID = state.burstID
                var index = state.indexInBurst
                if let last = state.lastTime, last.distance(to: input.time) <= interval {
                    index += 1
                } else {
                    burstID += 1
                    index = 1
                }
                return (
                    lastTime: input.time,
                    burstID: burstID,
                    indexInBurst: index,
                    value: input.value
                )
            }
            .map { (value: $0.value!, burstID: $0.burstID, indexInBurst: $0.indexInBurst) }
            .share()

        let leading = annotated
            .filter { $0.indexInBurst == 1 }
            .map { $0.value }

        let trailing = annotated
            .debounce(for: interval, scheduler: scheduler)
            .filter { $0.indexInBurst > 1 }
            .map { $0.value }

        return leading
            .merge(with: trailing)
            .eraseToAnyPublisher()
    }
}
