// TODO: Can't be public..?
// Forked from https://medium.com/geekculture/using-appstorage-with-swiftui-colors-and-some-nskeyedarchiver-magic-a38038383c5e
import SwiftUI

#if os(iOS) || os(tvOS) || os(visionOS)
import UIKit
typealias AppKitOrUIKitColor = UIColor
#endif

#if os(macOS)
import AppKit
typealias AppKitOrUIKitColor = NSColor
#endif

private struct ColorCache {
    static var cache: [String: Color] = [:]
}

extension Color: RawRepresentable {
    public init?(rawValue: String) {
        if let cachedColor = ColorCache.cache[rawValue] {
            self = cachedColor
            return
        }
        
        guard let data = Data(base64Encoded: rawValue) else {
            self = .black
            return
        }
        
        do {
            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: AppKitOrUIKitColor.self, from: data)
            let swiftUIColor = Color(color ?? AppKitOrUIKitColor.black)
            ColorCache.cache[rawValue] = swiftUIColor // Store in cache
            self = swiftUIColor
        } catch {
            self = .black
        }
    }

    public var rawValue: String {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: AppKitOrUIKitColor(self), requiringSecureCoding: false) as Data
            return data.base64EncodedString()
            
        } catch {
            return ""
        }
    }
}
