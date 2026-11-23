#if os(macOS)
import AppKit
import SwiftUI
import XCTest
@testable import SwiftUtilities

@MainActor
final class WindowAccessorTests: XCTestCase {
    func testReportDefersAttachedWindowPublication() async {
        let window = NSWindow()
        let storage = WindowAccessorStorage()
        let coordinator = WindowAccessor.Coordinator(binding: storage.binding)

        let report = coordinator.report(window)

        XCTAssertNil(storage.window)
        XCTAssertEqual(storage.updateCount, 0)
        await report.value
        XCTAssertTrue(storage.window === window)
        XCTAssertEqual(storage.updateCount, 1)
    }

    func testReportPublishesDetach() async {
        let storage = WindowAccessorStorage(window: NSWindow())
        let coordinator = WindowAccessor.Coordinator(binding: storage.binding)

        await coordinator.report(nil).value

        XCTAssertNil(storage.window)
        XCTAssertEqual(storage.updateCount, 1)
    }

    func testLatestRapidReparentReportWins() async {
        let firstWindow = NSWindow()
        let secondWindow = NSWindow()
        let storage = WindowAccessorStorage()
        let coordinator = WindowAccessor.Coordinator(binding: storage.binding)

        let firstReport = coordinator.report(firstWindow)
        let detachReport = coordinator.report(nil)
        let secondReport = coordinator.report(secondWindow)
        await secondReport.value
        await detachReport.value
        await firstReport.value

        XCTAssertTrue(storage.window === secondWindow)
        XCTAssertEqual(storage.updateCount, 1)
    }

    func testLatestDetachRejectsQueuedAttachment() async {
        let originalWindow = NSWindow()
        let storage = WindowAccessorStorage(window: originalWindow)
        let coordinator = WindowAccessor.Coordinator(binding: storage.binding)

        let attachmentReport = coordinator.report(NSWindow())
        let detachReport = coordinator.report(nil)
        await attachmentReport.value
        await detachReport.value

        XCTAssertNil(storage.window)
        XCTAssertEqual(storage.updateCount, 1)
    }

    func testBindingReplacementRejectsReportWithoutNewReport() async {
        let originalWindow = NSWindow()
        let currentWindow = NSWindow()
        let originalStorage = WindowAccessorStorage(window: originalWindow)
        let currentStorage = WindowAccessorStorage(window: currentWindow)
        let coordinator = WindowAccessor.Coordinator(binding: originalStorage.binding)

        let staleReport = coordinator.report(nil)
        coordinator.updateBinding(currentStorage.binding)
        await staleReport.value

        XCTAssertTrue(originalStorage.window === originalWindow)
        XCTAssertEqual(originalStorage.updateCount, 0)
        XCTAssertTrue(currentStorage.window === currentWindow)
        XCTAssertEqual(currentStorage.updateCount, 0)
    }

    func testBindingReplacementPublishesOnlyItsCurrentReport() async {
        let originalWindow = NSWindow()
        let staleWindow = NSWindow()
        let currentWindow = NSWindow()
        let originalStorage = WindowAccessorStorage(window: originalWindow)
        let currentStorage = WindowAccessorStorage()
        let coordinator = WindowAccessor.Coordinator(binding: originalStorage.binding)

        let staleReport = coordinator.report(staleWindow)
        coordinator.updateBinding(currentStorage.binding)
        let currentReport = coordinator.report(currentWindow)
        await staleReport.value
        await currentReport.value

        XCTAssertTrue(originalStorage.window === originalWindow)
        XCTAssertEqual(originalStorage.updateCount, 0)
        XCTAssertTrue(currentStorage.window === currentWindow)
        XCTAssertEqual(currentStorage.updateCount, 1)
    }

    func testBindingReplacementDuringReadRejectsReport() async {
        let staleWindow = NSWindow()
        let originalStorage = WindowAccessorStorage()
        let currentStorage = WindowAccessorStorage()
        let coordinator = WindowAccessor.Coordinator(binding: originalStorage.binding)
        originalStorage.onNextRead = {
            coordinator.updateBinding(currentStorage.binding)
        }

        await coordinator.report(staleWindow).value

        XCTAssertNil(originalStorage.onNextRead)
        XCTAssertNil(originalStorage.window)
        XCTAssertEqual(originalStorage.updateCount, 0)
        XCTAssertNil(currentStorage.window)
        XCTAssertEqual(currentStorage.updateCount, 0)
    }

    func testNewReportDuringReadRejectsOlderReport() async throws {
        let staleWindow = NSWindow()
        let currentWindow = NSWindow()
        let storage = WindowAccessorStorage()
        let coordinator = WindowAccessor.Coordinator(binding: storage.binding)
        var currentReport: Task<Void, Never>?
        storage.onNextRead = {
            currentReport = coordinator.report(currentWindow)
        }

        await coordinator.report(staleWindow).value
        let pendingCurrentReport = try XCTUnwrap(currentReport)
        await pendingCurrentReport.value

        XCTAssertNil(storage.onNextRead)
        XCTAssertTrue(storage.window === currentWindow)
        XCTAssertEqual(storage.updateCount, 1)
    }

    func testDuplicateReportDoesNotRewriteBinding() async {
        let window = NSWindow()
        let storage = WindowAccessorStorage(window: window)
        let coordinator = WindowAccessor.Coordinator(binding: storage.binding)

        let firstReport = coordinator.report(window)
        let secondReport = coordinator.report(window)
        await firstReport.value
        await secondReport.value

        XCTAssertTrue(storage.window === window)
        XCTAssertEqual(storage.updateCount, 0)
    }

    func testPendingReportDoesNotRetainCoordinator() async throws {
        let storage = WindowAccessorStorage()
        var coordinator: WindowAccessor.Coordinator? = WindowAccessor.Coordinator(binding: storage.binding)
        weak var weakCoordinator = coordinator

        let pendingReport = try XCTUnwrap(coordinator).report(NSWindow())
        coordinator = nil

        XCTAssertNil(weakCoordinator)
        await pendingReport.value
        XCTAssertNil(storage.window)
        XCTAssertEqual(storage.updateCount, 0)
    }
}

@MainActor
private final class WindowAccessorStorage {
    var window: NSWindow?
    var updateCount = 0
    var onNextRead: (() -> Void)?

    init(window: NSWindow? = nil) {
        self.window = window
    }

    var binding: Binding<NSWindow?> {
        Binding(
            get: {
                let onRead = self.onNextRead
                self.onNextRead = nil
                onRead?()
                return self.window
            },
            set: {
                self.window = $0
                self.updateCount += 1
            }
        )
    }
}
#endif
