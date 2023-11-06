//
//  CGSizeE.swift
//  Map Map
//
//  Created by Ben Roberts on 11/3/23.
//

import Foundation

extension CGSize {
    static func * (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width * rhs.width, height: lhs.height * rhs.height)
    }
    
    static func / (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width / rhs.width, height: lhs.width / rhs.width)
    }
    
    static func *= (lhs: inout CGSize, rhs: CGSize) {
        lhs.width *= rhs.height
        lhs.height *= rhs.height
    }
}
