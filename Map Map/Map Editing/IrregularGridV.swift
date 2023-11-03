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
    
    let gridLineCount: CGFloat = 2
    
    func path(in rect: CGRect) -> Path {
        let gridLineCount: CGFloat = self.gridLineCount + 1
        var path = Path()
        for i in stride(from: 0, through: gridLineCount, by: 1) { // I'm sorry this is a lot of repeated code for now <3
            // Horizontal lines
            path.move(
                to: CGPoint(
                    x: (bottomLeading.width - topLeading.width) / gridLineCount * i + topLeading.width,
                    y: (bottomLeading.height - topLeading.height) / gridLineCount * i + topLeading.height
                )
            )
            path.addLine(
                to: CGPoint(
                    x: (bottomTrailing.width - topTrailing.width) / gridLineCount * i + topTrailing.width,
                    y: (bottomTrailing.height - topTrailing.height) / gridLineCount * i + topTrailing.height
                )
            )
            
            // Vertical lines
            path.move(
                to: CGPoint(
                    x: (topTrailing.width - topLeading.width) / gridLineCount * i + topLeading.width,
                    y: (topTrailing.height - topLeading.height) / gridLineCount * i + topLeading.height
                )
            )
            path.addLine(
                to: CGPoint(
                    x: (bottomTrailing.width - bottomLeading.width) / gridLineCount * i + bottomLeading.width,
                    y: (bottomTrailing.height - bottomLeading.height) / gridLineCount * i + bottomLeading.height
                )
            )
        }
        return path
    }
}
