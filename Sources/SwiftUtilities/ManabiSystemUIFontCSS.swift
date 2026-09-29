import SwiftUI

public enum ManabiSystemUIFontVariable: String, CaseIterable {
    case caption = "--manabi-system-font-size-caption"
    case caption2 = "--manabi-system-font-size-caption2"
    case footnote = "--manabi-system-font-size-footnote"
    case callout = "--manabi-system-font-size-callout"
    case body = "--manabi-system-font-size-body"
    case subheadline = "--manabi-system-font-size-subheadline"
    case headline = "--manabi-system-font-size-headline"
    case title3 = "--manabi-system-font-size-title3"
    case title2 = "--manabi-system-font-size-title2"
    case title = "--manabi-system-font-size-title"
    case largeTitle = "--manabi-system-font-size-largeTitle"

    public var textStyle: Font.TextStyle {
        switch self {
        case .caption:
            return .caption
        case .caption2:
            return .caption2
        case .footnote:
            return .footnote
        case .callout:
            return .callout
        case .body:
            return .body
        case .subheadline:
            return .subheadline
        case .headline:
            return .headline
        case .title3:
            return .title3
        case .title2:
            return .title2
        case .title:
            return .title
        case .largeTitle:
            return .largeTitle
        }
    }
}

public enum ManabiSystemUIFontCSS {
    public static func fallbackSizeMap() -> [ManabiSystemUIFontVariable: CGFloat] {
        Dictionary(uniqueKeysWithValues: ManabiSystemUIFontVariable.allCases.map { variable in
            (variable, Font.pointSize(for: variable.textStyle))
        })
    }

    public static func cssDeclarations(from sizeMap: [ManabiSystemUIFontVariable: CGFloat]) -> String {
        ManabiSystemUIFontVariable.allCases.map { variable in
            "\(variable.rawValue): \(cssPointSizeString(sizeMap[variable] ?? Font.pointSize(for: variable.textStyle)))px;"
        }.joined(separator: " ")
    }

    public static func cssVariableValues(from sizeMap: [ManabiSystemUIFontVariable: CGFloat]) -> [String: String] {
        Dictionary(uniqueKeysWithValues: ManabiSystemUIFontVariable.allCases.map { variable in
            (
                variable.rawValue,
                "\(cssPointSizeString(sizeMap[variable] ?? Font.pointSize(for: variable.textStyle)))px"
            )
        })
    }

    private static func cssPointSizeString(_ value: CGFloat) -> String {
        let rounded = value.rounded()
        if abs(value - rounded) < 0.001 {
            return String(Int(rounded))
        }
        return String(format: "%.2f", value)
    }
}
