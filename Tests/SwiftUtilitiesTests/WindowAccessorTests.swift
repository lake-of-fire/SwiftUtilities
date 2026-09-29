#if os(macOS)
import AppKit
import SwiftUI
import XCTest
@testable import SwiftUtilities

@MainActor
final class WindowAccessorTests: XCTestCase {
    func testReportPublishesAttachedWindow() async {
        let window = NSWindow()
        let storage = WindowStorage()
        let coordinator = WindowAccessor.Coordinator(binding: storage.binding)

        coordinator.report(window)
        await settleDeferredReports()

        XCTAssertTrue(storage.window === window)
        XCTAssertEqual(storage.updateCount, 1)
    }

    func testReportPublishesDetach() async {
        let storage = WindowStorage(window: NSWindow())
        let coordinator = WindowAccessor.Coordinator(binding: storage.binding)

        coordinator.report(nil)
        await settleDeferredReports()

        XCTAssertNil(storage.window)
        XCTAssertEqual(storage.updateCount, 1)
    }

    func testLatestRapidReparentReportWins() async {
        let firstWindow = NSWindow()
        let secondWindow = NSWindow()
        let storage = WindowStorage()
        let coordinator = WindowAccessor.Coordinator(binding: storage.binding)

        coordinator.report(firstWindow)
        coordinator.report(nil)
        coordinator.report(secondWindow)
        await settleDeferredReports()

        XCTAssertTrue(storage.window === secondWindow)
        XCTAssertEqual(storage.updateCount, 1)
    }

    func testBindingReplacementRejectsReportForPreviousBinding() async {
        let originalWindow = NSWindow()
        let staleWindow = NSWindow()
        let currentWindow = NSWindow()
        let originalStorage = WindowStorage(window: originalWindow)
        let currentStorage = WindowStorage()
        let coordinator = WindowAccessor.Coordinator(binding: originalStorage.binding)

        coordinator.report(staleWindow)
        coordinator.updateBinding(currentStorage.binding)
        coordinator.report(currentWindow)
        await settleDeferredReports()

        XCTAssertTrue(originalStorage.window === originalWindow)
        XCTAssertEqual(originalStorage.updateCount, 0)
        XCTAssertTrue(currentStorage.window === currentWindow)
        XCTAssertEqual(currentStorage.updateCount, 1)
    }

    func testDuplicateReportDoesNotRewriteBinding() async {
        let window = NSWindow()
        let storage = WindowStorage(window: window)
        let coordinator = WindowAccessor.Coordinator(binding: storage.binding)

        coordinator.report(window)
        coordinator.report(window)
        await settleDeferredReports()

        XCTAssertTrue(storage.window === window)
        XCTAssertEqual(storage.updateCount, 0)
    }

    private func settleDeferredReports() async {
        await Task.yield()
        await Task.yield()
    }
}

@MainActor
private final class WindowStorage {
    var window: NSWindow?
    var updateCount = 0

    init(window: NSWindow? = nil) {
        self.window = window
    }

    var binding: Binding<NSWindow?> {
        Binding(
            get: { self.window },
            set: {
                self.window = $0
                self.updateCount += 1
            }
        )
    }
}
#endif
