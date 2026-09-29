import XCTest
@testable import SwiftUtilities

final class ManabiSystemUIFontCSSTests: XCTestCase {
    func testCSSDeclarationsIncludesAllVariablesInStableOrder() {
        let declarations = ManabiSystemUIFontCSS.cssDeclarations(from: [
            .caption: 11,
            .caption2: 10,
            .footnote: 13,
            .callout: 16,
            .body: 17,
            .subheadline: 15,
            .headline: 17,
            .title3: 20,
            .title2: 22,
            .title: 28,
            .largeTitle: 34
        ])

        XCTAssertEqual(
            declarations,
            "--manabi-system-font-size-caption: 11px; " +
                "--manabi-system-font-size-caption2: 10px; " +
                "--manabi-system-font-size-footnote: 13px; " +
                "--manabi-system-font-size-callout: 16px; " +
                "--manabi-system-font-size-body: 17px; " +
                "--manabi-system-font-size-subheadline: 15px; " +
                "--manabi-system-font-size-headline: 17px; " +
                "--manabi-system-font-size-title3: 20px; " +
                "--manabi-system-font-size-title2: 22px; " +
                "--manabi-system-font-size-title: 28px; " +
                "--manabi-system-font-size-largeTitle: 34px;"
        )
    }

    func testCSSVariableValuesFormatsFractionalSizes() {
        let values = ManabiSystemUIFontCSS.cssVariableValues(from: [
            .body: 16.5,
            .largeTitle: 30.25
        ])

        XCTAssertEqual(values["--manabi-system-font-size-body"], "16.50px")
        XCTAssertEqual(values["--manabi-system-font-size-largeTitle"], "30.25px")
    }

    func testFallbackSizeMapProvidesEverySystemFontVariable() {
        let sizeMap = ManabiSystemUIFontCSS.fallbackSizeMap()

        XCTAssertEqual(Set(sizeMap.keys), Set(ManabiSystemUIFontVariable.allCases))
        XCTAssertTrue(sizeMap.values.allSatisfy { $0 > 0 })
    }
}
