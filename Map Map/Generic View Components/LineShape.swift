//
//  LineShape.swift
//  Map Map
//
//  Created by Ben Roberts on 12/15/23.
//

import SwiftUI

struct Line: Shape {
    /// Screenspace starting position
    let startingPos: CGSize
    /// Screespace ending position.
    let endingPos: CGSize
    /// Draw line
    /// - Parameter rect: Ignored.
    /// - Returns: Generated path.
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(size: startingPos))
        path.addLine(to: CGPoint(size: endingPos))
        return path
    }
}
