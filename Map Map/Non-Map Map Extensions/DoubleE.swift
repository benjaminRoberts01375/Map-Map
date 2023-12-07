//
//  DoubleE.swift
//  Map Map
//
//  Created by Ben Roberts on 11/18/23.
//

import Foundation

extension Double {
    /// Simply check if self is between two values.
    /// - Parameters:
    ///   - min: Minimum value.
    ///   - max: Maximum value.
    /// - Returns: Bool determining if self is in between.
    func isBetween(min: Double, max: Double) -> Bool {
        return self > min && self < max
    }
}
