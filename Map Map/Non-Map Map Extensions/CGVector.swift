//
//  CGVector.swift
//  Map Map
//
//  Created by Ben Roberts on 11/4/23.
//

import CoreImage

extension CIVector {
    convenience init(cgSize: CGSize) {
        self.init(x: CGFloat(cgSize.width), y: CGFloat(cgSize.height))
    }
}
