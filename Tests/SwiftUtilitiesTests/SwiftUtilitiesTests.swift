import XCTest
import Combine
@testable import SwiftUtilities

final class DebounceLeadingTrailingTests: XCTestCase {
    var cancellables: Set<AnyCancellable> = []
    
    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }
    
    func testLeadingImmediateAndConditionalTrailing() {
        let queue = DispatchQueue(label: "debounceLeadingTrailing.tests.1")
        let subject = PassthroughSubject<Int, Never>()
        let interval: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(200)
        
        var outputs: [(value: Int, time: TimeInterval)] = []
        let start = Date()
        
        subject
            .debounceLeadingTrailing(for: interval, scheduler: queue)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { value in
                outputs.append((value, Date().timeIntervalSince(start)))
            })
            .store(in: &cancellables)
        
        let exp = expectation(description: "receive outputs")
        
        // Send 3 values within the quiet window
        queue.asyncAfter(deadline: .now() + .milliseconds(0))   { subject.send(1) }
        queue.asyncAfter(deadline: .now() + .milliseconds(50))  { subject.send(2) }
        queue.asyncAfter(deadline: .now() + .milliseconds(100)) { subject.send(3) }
        
        // Allow time for trailing debounce to fire after the last input
        queue.asyncAfter(deadline: .now() + .milliseconds(450)) { exp.fulfill() }
        
        wait(for: [exp], timeout: 1.2)
        
        XCTAssertGreaterThanOrEqual(outputs.count, 2, "Should emit leading and then a trailing for a multi-event burst")
        XCTAssertEqual(outputs.first?.value, 1, "Leading should be the first value")
        // Leading should be effectively immediate (< 80ms)
        if let t0 = outputs.first?.time {
            XCTAssertLessThan(t0, 0.08, "Leading should be emitted immediately, not debounced")
        }
        // Trailing should be last value in burst and occur ~ interval after the last event
        let trailing = outputs.last!
        XCTAssertEqual(trailing.value, 3, "Trailing should be the last value of the burst")
        XCTAssertGreaterThan(trailing.time, 0.28, "Trailing should occur after the debounce window")
    }
    
    func testNoTrailingWhenSingleEvent() {
        let queue = DispatchQueue(label: "debounceLeadingTrailing.tests.2")
        let subject = PassthroughSubject<Int, Never>()
        let interval: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(150)
        
        var outputs: [Int] = []
        
        subject
            .debounceLeadingTrailing(for: interval, scheduler: queue)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { outputs.append($0) })
            .store(in: &cancellables)
        
        let exp = expectation(description: "single")
        queue.async { subject.send(42) }
        queue.asyncAfter(deadline: .now() + .milliseconds(400)) { exp.fulfill() }
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(outputs, [42], "Only the leading value should be emitted when there is no subsequent activity")
    }
    
    func testSeparateBursts() {
        let queue = DispatchQueue(label: "debounceLeadingTrailing.tests.3")
        let subject = PassthroughSubject<Int, Never>()
        let interval: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(120)
        
        var outputs: [Int] = []
        
        subject
            .debounceLeadingTrailing(for: interval, scheduler: queue)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { outputs.append($0) })
            .store(in: &cancellables)
        
        let exp = expectation(description: "bursts")
        
        // Burst A: two events within the window -> leading 10, trailing 11
        queue.async { subject.send(10) }
        queue.asyncAfter(deadline: .now() + .milliseconds(40)) { subject.send(11) }
        
        // Gap > interval to ensure a new burst
        queue.asyncAfter(deadline: .now() + .milliseconds(300)) { subject.send(20) }
        
        // Another value within the second window -> trailing 21
        queue.asyncAfter(deadline: .now() + .milliseconds(340)) { subject.send(21) }
        
        // Enough time for all debounces to fire
        queue.asyncAfter(deadline: .now() + .milliseconds(700)) { exp.fulfill() }
        
        wait(for: [exp], timeout: 2.0)
        
        XCTAssertEqual(outputs, [10, 11, 20, 21],
                       "Should emit leading and conditional trailing per burst")
    }
}
