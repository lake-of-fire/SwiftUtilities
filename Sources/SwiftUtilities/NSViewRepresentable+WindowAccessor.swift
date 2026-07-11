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

    public final class Coordinator {
        fileprivate var binding: Binding<NSWindow?>

        fileprivate init(binding: Binding<NSWindow?>) {
            self.binding = binding
        }

        fileprivate func report(_ window: NSWindow?) {
            Task { @MainActor [weak self] in
                guard let self, binding.wrappedValue !== window else { return }
                binding.wrappedValue = window
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
        context.coordinator.binding = binding
        context.coordinator.report(nsView.window)
    }
}
#endif
