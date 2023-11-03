//
//  CGSizeE.swift
//  Map Map
//
//  Created by Ben Roberts on 11/3/23.
//

import Foundation

extension CGSize {
    static func * (size: CGSize, factor: CGFloat) -> CGSize {
        return CGSize(width: size.width * factor, height: size.height * factor)
    }
    
    static func / (size: CGSize, factor: CGFloat) -> CGSize {
        return CGSize(width: size.width / factor, height: size.height / factor)
    }
    
    static func *= (size: inout CGSize, factor: CGFloat) {
            size.width *= factor
            size.height *= factor
    }
}
