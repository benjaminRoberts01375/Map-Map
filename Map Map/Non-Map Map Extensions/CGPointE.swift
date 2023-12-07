//
//  CGPointE.swift
//  Map Map
//
//  Created by Ben Roberts on 11/2/23.
//

import SwiftUI

extension CGPoint {
    /// Create a CGPoint from a CGSize
    /// - Parameter size: Base CGSize
    init(size: CGSize) {
        self.init(x: size.width, y: size.height)
    }
}
