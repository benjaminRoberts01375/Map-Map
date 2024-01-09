//
//  CGSizeE.swift
//  Map Map
//
//  Created by Ben Roberts on 11/3/23.
//

import Foundation

extension CGSize {
    /// Create a CGSize from a CGPoint.
    /// - Parameter cgPoint: CGPoint to convert.
    init(cgPoint: CGPoint) {
        self.init(width: cgPoint.x, height: cgPoint.y)
    }
    
    static func * (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width * rhs.width, height: lhs.height * rhs.height)
    }
    
    /// Allows dividing a CGSize by another CGSize
    /// - Parameters:
    ///   - lhs: Dividend
    ///   - rhs: Divisor
    /// - Returns: Quotient
    static func / (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width / rhs.width, height: lhs.width / rhs.width)
    }
    
    /// Allows dividing a CGSize by a CGFloat.
    /// - Parameters:
    ///   - lhs: CGSize to divide.
    ///   - rhs: CGFloat to divide by.
    /// - Returns: Divided CGSize.
    static func / (lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }
    
    /// Allow \*= operation of of CGSize
    /// - Parameters:
    ///   - lhs: CGSize being multiplied.
    ///   - rhs: Multiplier.
    static func *= (lhs: inout CGSize, rhs: CGSize) {
        lhs.width *= rhs.width
        lhs.height *= rhs.height
    }
    
    /// Allow rounding of CGSizes
    /// - Returns: A rounded CGSize
    func rounded() -> CGSize {
        return CGSize(width: width.rounded(), height: height.rounded())
    }
    
    /// Calculate the distance to another CGSize.
    /// - Parameter destination: Destination CGSize.
    /// - Returns: Distance between the two CGSizes.
    func distanceTo(_ destination: CGSize) -> CGFloat {
        return sqrt(pow(self.width - destination.width, 2) + pow(self.height - destination.height, 2))
    }
}
