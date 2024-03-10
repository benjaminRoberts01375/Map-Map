//
//  CGPointE.swift
//  Map Map
//
//  Created by Ben Roberts on 11/2/23.
//

import SwiftUI

extension CGPoint: Hashable {
    /// Create a CGPoint from a CGSize
    /// - Parameter size: Base CGSize
    init(size: CGSize) {
        self.init(x: size.width, y: size.height)
    }
    
    /// Calculate the distance to another CGPoint.
    /// - Parameter destination: Destination CGPoint.
    /// - Returns: Distance between the two CGPoints.
    func distanceTo(_ destination: CGPoint) -> CGFloat {
        return sqrt(pow(self.x - destination.x, 2) + pow(self.y - destination.y, 2))
    }
    
    /// Conformance to hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
    
    /// Allow equating of two CGPoints.
    /// - Parameters:
    ///   - lhs: Left CGPoint
    ///   - rhs: Right CGPoint
    /// - Returns: Boolean result.
    public static func == (lhs: CGPoint, rhs: CGPoint) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}
