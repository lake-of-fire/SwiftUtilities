import SwiftUI

// Forked from https://github.com/CodeSlicing/pure-swift-ui/blob/dcad7b0a144af72ad7ef14323e8267b8d851477b/Sources/PureSwiftUI/Extensions/SwiftUI/Views/Modifiers/View%2BModifiers.swift#L611
public extension View {
    func geometryReader(_ geoCallback: @escaping (GeometryProxy) -> ()) -> some View {
        geometryReader(id: 1, geoCallback)
    }
    
    func geometryReader<T: Hashable>(id: T, _ geoCallback: @escaping (GeometryProxy) -> ()) -> some View {
        overlay(GeometryReader { (geo: GeometryProxy) in
            Color.clear.onAppear {
                geoCallback(geo)
            }
            .id(id)
        })
    }
}
