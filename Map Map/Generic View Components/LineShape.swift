//
//  LineShape.swift
//  Map Map
//
//  Created by Ben Roberts on 12/15/23.
//

import SwiftUI

struct Line: Shape {
    let startingPos: CGSize
    let endingPos: CGSize
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(size: startingPos))
        path.addLine(to: CGPoint(size: endingPos))
        return path
    }
}
