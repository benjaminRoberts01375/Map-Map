//
//  MultiLineShape.swift
//  Map Map
//
//  Created by Ben Roberts on 3/8/24.
//

import SwiftUI

struct MultiLine: Shape {
    var points: [CGPoint]
    
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
