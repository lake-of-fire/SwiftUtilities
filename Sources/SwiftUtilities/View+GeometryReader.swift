import SwiftUI
import DebouncedOnChange

//// Forked from https://github.com/CodeSlicing/pure-swift-ui/blob/dcad7b0a144af72ad7ef14323e8267b8d851477b/Sources/PureSwiftUI/Extensions/SwiftUI/Views/Modifiers/View%2BModifiers.swift#L611
public extension View {
    func geometryReader(_ geoCallback: @escaping (GeometryProxy) -> ()) -> some View {
        geometryReader(id: 1, geoCallback)
    }
    
    func geometryReader<T: Hashable>(id: T, _ geoCallback: @escaping (GeometryProxy) -> ()) -> some View {
        overlay(GeometryReader { (geo: GeometryProxy) in
            Color.clear
                .onAppear {
                    geoCallback(geo)
                }
                .onChange(of: geo, debounceTime: 0.01) { geo in
                    geoCallback(geo)
                }
            .id(id)
        })
    }
}

//// Forked from https://gist.github.com/GeorgeElsham/1f3f0eef3bd986a1d3d1a6715e52e9ba
//fileprivate struct GeometryReaderModifier: ViewModifier {
//    private struct GeometryPreferenceKey: PreferenceKey {
//        static func reduce(value: inout GeometryProxy?, nextValue: () -> GeometryProxy?) {
//            value = nextValue()
//        }
//    }
//    
//    private let geometry: (GeometryProxy) -> Void
//    
//    init(geometry: @escaping (GeometryProxy) -> Void) {
//        self.geometry = geometry
//    }
//    
//    func body(content: Content) -> some View {
//        content
//            .background(
//                GeometryReader { geo in
//                    Color.clear
//                        .preference(key: GeometryPreferenceKey.self, value: geo)
//                }
//            )
//            .onPreferenceChange(GeometryPreferenceKey.self) { geo in
//                if let geo = geo {
//                    geometry(geo)
//                }
//            }
//    }
//}
//
//public extension View {
//    /// Read the geometry of the current view. Save the returned value in
//    /// a `@State` variable, to be used anywhere within the view.
//    ///
//    /// - Parameter geometry: Geometry closure containing this view's geometry.
//    /// - Returns: Modified view.
//    func geometryReader(_ geometry: @escaping (GeometryProxy) -> Void) -> some View {
//        modifier(GeometryReaderModifier(geometry: geometry))
//    }
//}


extension GeometryProxy: Equatable {
    public static func == (lhs: GeometryProxy, rhs: GeometryProxy) -> Bool {
        lhs.frame(in: .global) == rhs.frame(in: .global) && lhs.safeAreaInsets == rhs.safeAreaInsets && lhs.size == rhs.size
    }
}
