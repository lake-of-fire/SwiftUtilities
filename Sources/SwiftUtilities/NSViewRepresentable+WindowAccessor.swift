//
//  File.swift
//  
//
//  Created by Alex Ehlke on 7/3/22.
//

#if os(macOS)
import Foundation
import SwiftUI
import AppKit

public struct WindowAccessor: NSViewRepresentable {
    private var binding: Binding<NSWindow?>

    @MainActor
    public final class Coordinator {
        private var binding: Binding<NSWindow?>
        private var bindingGeneration: UInt = 0
        private var reportGeneration: UInt = 0

        init(binding: Binding<NSWindow?>) {
            self.binding = binding
        }

        func updateBinding(_ binding: Binding<NSWindow?>) {
            bindingGeneration &+= 1
            reportGeneration &+= 1
            self.binding = binding
        }

        @discardableResult
        func report(_ window: NSWindow?) -> Task<Void, Never> {
            reportGeneration &+= 1
            let expectedBindingGeneration = bindingGeneration
            let expectedReportGeneration = reportGeneration

            return Task { @MainActor [weak self] in
                guard let self,
                      bindingGeneration == expectedBindingGeneration,
                      reportGeneration == expectedReportGeneration else {
                    return
                }

                let currentBinding = binding
                // A custom binding getter can replace the binding or enqueue another report.
                guard currentBinding.wrappedValue !== window,
                      bindingGeneration == expectedBindingGeneration,
                      reportGeneration == expectedReportGeneration else {
                    return
                }
                currentBinding.wrappedValue = window
            }
        }
    }

    public final class ReportingView: NSView {
        fileprivate weak var coordinator: Coordinator?

        public override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            coordinator?.report(window)
        }
    }
    
    public init(for binding: Binding<NSWindow?>) {
        self.binding = binding
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(binding: binding)
    }

    public func makeNSView(context: Context) -> ReportingView {
        let view = ReportingView()
        view.coordinator = context.coordinator
        return view
    }

    public func updateNSView(_ nsView: ReportingView, context: Context) {
        context.coordinator.updateBinding(binding)
        context.coordinator.report(nsView.window)
    }
}
#endif
