//
//  WHStack.swift
//  Map Map
//
//  Created by Ben Roberts on 11/28/23.
//

import SwiftUI

fileprivate final class ViewRow {
    private(set) var subviews: [LayoutSubviews.Element] = []
    var size: CGSize = .zero
    
    public func addSubview(_ subview: LayoutSubviews.Element) {
        let subviewSize = subview.sizeThatFits(.unspecified)
        let previousSpacing: CGFloat = subviews.isEmpty ? 0 : subviews[subviews.count - 1].spacing.distance(to: subview.spacing, along: .horizontal)
        
        size = CGSize(
            width: size.width + subviewSize.width + previousSpacing,
            height: max(size.height, subviewSize.height)
        )
        subviews.append(subview)
    }
}

public struct WHStack: Layout {
    
    /// Deterrmine size of the WHStack
    /// - Parameters:
    ///   - proposal: Proposed size for the WHStack
    ///   - subviews: Views within the WHStack
    ///   - cache: Cache for placeSubviews
    /// - Returns: Size of WHStack
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard let proposedWidth = proposal.width else { return .zero }
        // Generate rows
        let rows: [ViewRow] = generateRows(subviews: subviews, width: proposedWidth)
        
        // Determine width of widest row
        let maxWidth: CGFloat = rows.reduce(0) { max($0, $1.size.width) }
        
        // Make CGSize & return it
        return CGSize(
            width: maxWidth,
            height: rows.reduce(0) { $0 + $1.size.height }
        )
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard !subviews.isEmpty else { return }
        let rows: [ViewRow] = generateRows(subviews: subviews, width: bounds.width)
        var currentHeight = bounds.minY
        for row in rows {
            var currentXPos = bounds.minX
            for subviewIndex in row.subviews.indices {
                row.subviews[subviewIndex].place(
                    at: CGPoint(
                        x: currentXPos,
                        y: currentHeight
                    ),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(row.subviews[subviewIndex].sizeThatFits(.unspecified))
                )
                currentXPos += row.subviews[subviewIndex].sizeThatFits(.unspecified).width
                if subviewIndex != row.subviews.count - 1 {
                    currentXPos += row.subviews[subviewIndex].spacing.distance(
                        to: row.subviews[subviewIndex + 1].spacing,
                        along: .horizontal
                    )
                }
            }
            currentHeight += row.size.height
        }
    }
    
    fileprivate func generateRows(subviews: Subviews, width: CGFloat) -> [ViewRow] {
        var rows: [ViewRow] = []
        let spacing: [CGFloat] = spacing(subviews: subviews)
        var currentViewRow: ViewRow = ViewRow()
        for subviewIndex in subviews.indices {
            let subviewWidth = subviews[subviewIndex].sizeThatFits(.unspecified).width
            if subviewWidth + currentViewRow.size.width + spacing[subviewIndex] <= width {
                currentViewRow.addSubview(subviews[subviewIndex])
            }
            else {
                rows.append(currentViewRow)
                currentViewRow = ViewRow()
                currentViewRow.addSubview(subviews[subviewIndex])
            }
        }
        rows.append(consume currentViewRow)
        return rows
    }
    
    private func spacing(subviews: Subviews) -> [CGFloat] {
        return subviews.enumerated().map { index, subview in
            guard index < subviews.count - 1 else { return 0 }
            return subview.spacing.distance(to: subviews[index + 1].spacing, along: .horizontal)
        }
    }
}
