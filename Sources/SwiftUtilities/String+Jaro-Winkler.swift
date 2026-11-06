//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

public extension String {
    /// Jaro-Winkler distance between two strings, to evaluate a potential match
    /// - Parameter string: The other string to evaluate the distance from
    /// Matching is case-insensitive. Empty strings have no match, including with each other.
    /// - Returns: Double between 0 and 1. 0 means no match at all. 1 means a perfect equality between nonempty strings.
    ///
    /// Useful links:
    /// - [Wikipedia](https://en.wikipedia.org/wiki/Jaro–Winkler_distance)
    func jaroWinklerDistance(from string: String) -> Double { JaroWinklerDistance(self, string).computeDistance() }
    
    func bestJaroWinklerMatchIn(propositions: [String]) -> String? {
        guard
            let bestMath = propositions.max(by: { jaroWinklerDistance(from: $0) < jaroWinklerDistance(from: $1) }),
            jaroWinklerDistance(from: bestMath) >= 0.5
        else { return nil }
        
        return bestMath
    }
}

/// Wrap the computations for the Jaro-Winkler
///
/// Useful links:
/// - [Wikipedia](https://en.wikipedia.org/wiki/Jaro–Winkler_distance)
private struct JaroWinklerDistance {
    let string1: [String]
    let string2: [String]

    init(_ string1: String, _ string2: String) {
        self.string1 = string1.map { $0.lowercased() }
        self.string2 = string2.map { $0.lowercased() }
    }

    func computeDistance() -> Double {
        guard !string1.isEmpty, !string2.isEmpty else { return 0 }

        let maxSpacing = max(0, max(string1.count, string2.count) / 2 - 1)
        var matched1 = Array(repeating: false, count: string1.count)
        var matched2 = Array(repeating: false, count: string2.count)
        var matches = 0

        for index in string1.indices {
            let lowerBound = max(0, index - maxSpacing)
            let upperBound = min(string2.count, index + maxSpacing + 1)
            guard lowerBound < upperBound else { continue }

            for candidate in lowerBound..<upperBound
            where !matched2[candidate] && string1[index] == string2[candidate] {
                matched1[index] = true
                matched2[candidate] = true
                matches += 1
                break
            }
        }

        guard matches > 0 else { return 0 }

        // Compare the matched subsequences in their original order, not original positions.
        let sequence1 = string1.indices.filter { matched1[$0] }.map { string1[$0] }
        let sequence2 = string2.indices.filter { matched2[$0] }.map { string2[$0] }
        let transpositions = Double(zip(sequence1, sequence2).filter { $0.0 != $0.1 }.count) / 2
        let m = Double(matches)
        let jaro = (m / Double(string1.count) + m / Double(string2.count)
                    + (m - transpositions) / m) / 3

        // Winkler's prefix boost applies only to sufficiently similar strings.
        guard jaro > 0.7 else { return jaro }
        let prefixLength = zip(string1, string2).prefix(4).prefix { $0.0 == $0.1 }.count
        return jaro + Double(prefixLength) * 0.1 * (1 - jaro)
    }
}
