import XCTest
@testable import SwiftUtilities

final class JaroWinklerTests: XCTestCase {
    func testPublishedReferenceScores() {
        assertScore("MARTHA", "MARHTA", equals: 0.9611111111111111)
        assertScore("DIXON", "DICKSONX", equals: 0.8133333333333332)
        assertScore("JELLYFISH", "SMELLYFISH", equals: 0.8962962962962964)
    }

    func testShortJapaneseStrings() {
        for text in ["猫", "日本", "日本語"] {
            assertScore(text, text, equals: 1)
            XCTAssertEqual(text.bestJaroWinklerMatchIn(propositions: ["無関係", text]), text)
        }
        assertScore("猫", "犬", equals: 0)
        assertScore("猫犬", "猫鳥", equals: 2.0 / 3.0)
        assertScore("日本語", "日本人", equals: 37.0 / 45.0)
    }

    func testRepeatedCharactersCannotReuseMatches() {
        assertScore("AAAA", "AA", equals: 13.0 / 15.0)
        assertScore("AAAA", "AAAB", equals: 53.0 / 60.0)
        assertScore("AAAB", "ABBB", equals: 2.0 / 3.0)
    }

    func testCaseInsensitiveMatchingAlsoAppliesToPrefixAndTranspositions() {
        assertScore("a", "A", equals: 1)
        assertScore("AbC", "abc", equals: 1)
        assertScore("martha", "MARHTA", equals: 0.9611111111111111)
        assertScore("É猫", "é猫", equals: 1)
    }

    func testEmptyStringsHaveNoMatch() {
        assertScore("", "", equals: 0)
        assertScore("", "猫", equals: 0)
        XCTAssertNil("".bestJaroWinklerMatchIn(propositions: ["", "猫"]))
    }

    func testBestMatchUsesScoreAndThreshold() {
        XCTAssertNil("猫".bestJaroWinklerMatchIn(propositions: []))
        XCTAssertNil("猫".bestJaroWinklerMatchIn(propositions: ["犬", "鳥"]))
        XCTAssertEqual("日本語".bestJaroWinklerMatchIn(propositions: ["犬", "日本人"]), "日本人")
        XCTAssertEqual("MARTHA".bestJaroWinklerMatchIn(propositions: ["DIXON", "MARHTA"]), "MARHTA")
    }

    private func assertScore(
        _ lhs: String,
        _ rhs: String,
        equals expected: Double,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(lhs.jaroWinklerDistance(from: rhs), expected, accuracy: 1e-12, file: file, line: line)
        XCTAssertEqual(rhs.jaroWinklerDistance(from: lhs), expected, accuracy: 1e-12, file: file, line: line)
    }
}
