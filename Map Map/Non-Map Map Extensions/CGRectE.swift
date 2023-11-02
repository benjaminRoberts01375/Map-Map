//
//  CGRectE.swift
//  Map Map
//
//  Created by Ben Roberts on 11/2/23.
//

import SwiftUI

extension CGRect {
    init(minX: CGFloat, minY: CGFloat, maxX: CGFloat, maxY: CGFloat) {
        self.init(x: (minX + maxX) / 2, y: (minY + maxY) / 2, width: maxX - minX, height: maxY - minY)
    }
}
