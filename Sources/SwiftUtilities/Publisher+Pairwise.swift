//
//  Combine+Pairwise.swift
//
//  Created by Felix Mau on 17.05.21.
//  Copyright © 2021 Felix Mau. All rights reserved.
//

import Combine

extension Publisher {
    
    typealias Pairwise<T> = (previous: T?, current: T)
    
    /// Includes the current element as well as the previous element from the upstream publisher in a tuple where the previous element is optional.
    /// The first time the upstream publisher emits an element, the previous element will be `nil`.
    ///
    /// ```
    /// let range = (1...5)
    /// let subscription = range.publisher
    ///   .pairwise()
    ///   .sink { print("(\($0.previous), \($0.current))", terminator: " ") }
    /// ```
    /// Prints: "(nil, 1) (Optional(1), 2) (Optional(2), 3) (Optional(3), 4) (Optional(4), 5)".
    ///
    /// - Returns: A publisher of a tuple of the previous and current elements from the upstream publisher.
    ///
    /// - Note: Based on <https://stackoverflow.com/a/67133582/3532505>.
    func pairwise() -> AnyPublisher<Pairwise<Output>, Failure> {
        // `scan()` needs an initial value, which is `nil` in our case.
        // Therefore we have to return an optional here and use `compactMap()` below the remove the optional type.
        scan(nil) { previousPair, currentElement -> Pairwise<Output>? in
            Pairwise(previous: previousPair?.current, current: currentElement)
        }
        .compactMap { $0 }
        .eraseToAnyPublisher()
    }
}
