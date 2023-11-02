//
//  IrregularGridV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/2/23.
//

import SwiftUI

struct IrregularGridV: Shape {
    let topLeading: CGSize
    let topTrailing: CGSize
    let bottomLeading: CGSize
    let bottomTrailing: CGSize
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(size: topLeading))
        path.addLine(to: CGPoint(size: topTrailing))
        path.addLine(to: CGPoint(size: bottomTrailing))
        path.addLine(to: CGPoint(size: bottomLeading))
        path.addLine(to: CGPoint(size: topLeading))
        return path
    }
}
