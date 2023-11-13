//
//  IrregularGridV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/2/23.
//

import SwiftUI

struct IrregularGridV: Shape {
    private let topLeading: CGSize
    private let topTrailing: CGSize
    private let bottomLeading: CGSize
    private let leadingHorizontalProportion: CGPoint
    private let trailingHorizontalProportion: CGPoint
    private let leadingVerticalProportion: CGPoint
    private let trailingVerticalProportion: CGPoint
    
    private let gridLineCount: CGFloat
    
    init(topLeading: CGSize, topTrailing: CGSize, bottomLeading: CGSize, bottomTrailing: CGSize, gridLineCount: CGFloat = 2) {
        self.gridLineCount = gridLineCount + 1
        self.leadingHorizontalProportion = CGPoint(
            x: (bottomLeading.width - topLeading.width) / self.gridLineCount,
            y: (bottomLeading.height - topLeading.height) / self.gridLineCount
        )
        self.trailingHorizontalProportion = CGPoint(
            x: (bottomTrailing.width - topTrailing.width) / self.gridLineCount,
            y: (bottomTrailing.height - topTrailing.height) / self.gridLineCount
        )
        self.leadingVerticalProportion = CGPoint(
            x: (topTrailing.width - topLeading.width) / self.gridLineCount,
            y: (topTrailing.height - topLeading.height) / self.gridLineCount
        )
        self.trailingVerticalProportion = CGPoint(
            x: (bottomTrailing.width - bottomLeading.width) / self.gridLineCount,
            y: (bottomTrailing.height - bottomLeading.height) / self.gridLineCount
        )
        self.topLeading = topLeading
        self.topTrailing = topTrailing
        self.bottomLeading = bottomLeading
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        for i in stride(from: 0, through: gridLineCount, by: 1) {
            // Horizontal lines
            path.move(
                to: CGPoint(
                    x: leadingHorizontalProportion.x * i + topLeading.width,
                    y: leadingHorizontalProportion.y * i + topLeading.height
                )
            )
            path.addLine(
                to: CGPoint(
                    x: trailingHorizontalProportion.x * i + topTrailing.width,
                    y: trailingHorizontalProportion.y * i + topTrailing.height
                )
            )
            
            // Vertical lines
            path.move(
                to: CGPoint(
                    x: leadingVerticalProportion.x * i + topLeading.width,
                    y: leadingVerticalProportion.y * i + topLeading.height
                )
            )
            path.addLine(
                to: CGPoint(
                    x: trailingVerticalProportion.x * i + bottomLeading.width,
                    y: trailingVerticalProportion.y * i + bottomLeading.height
                )
            )
        }
        return path
    }
}
