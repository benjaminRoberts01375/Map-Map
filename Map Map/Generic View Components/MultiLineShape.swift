//
//  MultiLineShape.swift
//  Map Map
//
//  Created by Ben Roberts on 3/8/24.
//

import SwiftUI

struct MultiLine: Shape {
    /// Points in order to draw.
    var points: [CGPoint]
    
    /// Draw several lines together.
    /// - Parameter rect: Ignored.
    /// - Returns: Generated path.
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let firstPoint = points.first else { return path }
        path.move(to: firstPoint)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        return path
    }
}
