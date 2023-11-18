//
//  DoubleE.swift
//  Map Map
//
//  Created by Ben Roberts on 11/18/23.
//

import Foundation

extension Double {
    func isBetween(min: Double, max: Double) -> Bool {
        return self > min && self < max
    }
}
