//
//  IrregularGridV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/2/23.
//

import SwiftUI

/// Similar to the idea of irregular shaps being warped versions of the regular, the irregular grid is a warped version of a grid.
struct IrregularGridV: Shape {
    /// Top leading point of the grid.
    private let topLeading: CGSize
    /// Top trailing point of the grid.
    private let topTrailing: CGSize
    /// Bottom leading point of the grid.
    private let bottomLeading: CGSize
    /// The offset from the topLeading point per horizontal line placed.
    private let leadingHorizontalProportion: CGPoint
    /// The offset from the topTrailing point per lhorizontal ine placed.
    private let trailingHorizontalProportion: CGPoint
    /// The offset from the topLeading point per vertical line placed.
    private let leadingVerticalProportion: CGPoint
    /// The offset from the bottomLeading point per verticalLine placed.
    private let trailingVerticalProportion: CGPoint
    /// Number of mid-lines to draw.
    private let gridLineCount: CGFloat
    
    /// Create an irregularly sized grid from points.
    /// - Parameters:
    ///   - topLeading: Top leading point of the irregular grid.
    ///   - topTrailing: Top trailing point of the irregular grid.
    ///   - bottomLeading: bottom leading point of the irregular grid.
    ///   - bottomTrailing: bottom trailing point of the irregular grid.
    ///   - gridLineCount: Number of mid-lines to draw.
    public init(topLeading: CGSize, topTrailing: CGSize, bottomLeading: CGSize, bottomTrailing: CGSize, gridLineCount: CGFloat = 2) {
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
    
    /// Implement path function for shape protocol.
    /// - Parameter rect: Unused
    /// - Returns: Drawn grid.
    func path(in rect: CGRect) -> Path {
        var path = Path()
        for lineIndex in stride(from: 0, through: gridLineCount, by: 1) {
            // Horizontal lines
            path.move(
                to: CGPoint(
                    x: leadingHorizontalProportion.x * lineIndex + topLeading.width,
                    y: leadingHorizontalProportion.y * lineIndex + topLeading.height
                )
            )
            path.addLine(
                to: CGPoint(
                    x: trailingHorizontalProportion.x * lineIndex + topTrailing.width,
                    y: trailingHorizontalProportion.y * lineIndex + topTrailing.height
                )
            )
            
            // Vertical lines
            path.move(
                to: CGPoint(
                    x: leadingVerticalProportion.x * lineIndex + topLeading.width,
                    y: leadingVerticalProportion.y * lineIndex + topLeading.height
                )
            )
            path.addLine(
                to: CGPoint(
                    x: trailingVerticalProportion.x * lineIndex + bottomLeading.width,
                    y: trailingVerticalProportion.y * lineIndex + bottomLeading.height
                )
            )
        }
        return path
    }
}
