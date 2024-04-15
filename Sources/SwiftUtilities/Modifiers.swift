import SwiftUI

public extension View {
    /// Modify a view with a `ViewBuilder` closure.
    ///
    /// This represents a streamlining of the
    /// [`modifier`](https://developer.apple.com/documentation/swiftui/view/modifier(_:))
    /// \+ [`ViewModifier`](https://developer.apple.com/documentation/swiftui/viewmodifier)
    /// pattern.
    /// - Note: Useful only when you don't need to reuse the closure.
    /// If you do, turn the closure into an extension! ♻️
    func modifier<ModifiedContent: View>(
        @ViewBuilder body: (_ content: Self) -> ModifiedContent
    ) -> ModifiedContent {
        body(self)
    }
}

struct ScrollDisabledIfAvailableModifier: ViewModifier {
    var disabled: Bool

    func body(content: Content) -> some View {
        if #available(iOS 16, macOS 13, *) {
            content
                .scrollDisabled(disabled)
        } else {
            content
        }
    }
}

public extension View {
    func scrollDisabledIfAvailable(_ disabled: Bool) -> some View {
        modifier(ScrollDisabledIfAvailableModifier(disabled: disabled))
    }
}

struct ScrollContentBackgroundIfAvailableModifier: ViewModifier {
    var visibility: Visibility

    func body(content: Content) -> some View {
        if #available(iOS 16, macOS 13, *) {
            content
                .scrollContentBackground(visibility)
        } else {
            content
        }
    }
}

public extension View {
    func scrollContentBackgroundIfAvailable(_ visibility: Visibility) -> some View {
        modifier(ScrollContentBackgroundIfAvailableModifier(visibility: visibility))
    }
}

struct ListRowSeparatorIfAvailableModifier: ViewModifier {
    var visibility: Visibility

    func body(content: Content) -> some View {
        if #available(iOS 16, macOS 13, *) {
            content
                .listRowSeparator(visibility)
        } else {
            content
        }
    }
}

public extension View {
    func listRowSeparatorIfAvailable(_ visibility: Visibility) -> some View {
        modifier(ListRowSeparatorIfAvailableModifier(visibility: visibility))
    }
}
struct GroupedFormStyleIfAvailableModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16, macOS 13, *) {
            content
                .formStyle(.grouped)
        } else {
            content
        }
    }
}

public extension View {
    func groupedFormStyleIfAvailable() -> some View {
        modifier(GroupedFormStyleIfAvailableModifier())
    }
}

struct ToolbarHiddenIfAvailableModifier: ViewModifier {
    func body(content: Content) -> some View {
        Group {
            if #available(iOS 16, macOS 13, *) {
                content
                    .toolbar(.hidden)
            } else {
#if os(iOS)
                content
                    .navigationBarHidden(true)
#else
                content
#endif
            }
        }
    }
}

public extension View {
    func toolbarHiddenIfAvailable() -> some View {
        modifier(GroupedFormStyleIfAvailableModifier())
    }
}
