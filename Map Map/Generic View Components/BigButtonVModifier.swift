//
//  BigButtonV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/15/23.
//

import SwiftUI

/// Format the label of a button to appear as a large button for the bottom drawers.
struct BigButton: ViewModifier {
    /// Background color.
    let background: Color
    /// The minimum width of the view.
    let minWidth: CGFloat
    /// The maximum width of the view.
    let maxWidth: CGFloat
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(.white)
            .frame(minWidth: minWidth, maxWidth: max(maxWidth, minWidth + 1), minHeight: 40)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

extension View {
    /// Format the label of a button to appear as a large button for the bottom drawers.
    func bigButton(backgroundColor background: Color, minWidth: CGFloat = 90, maxWidth: CGFloat = 90) -> some View {
        return modifier(BigButton(background: background, minWidth: minWidth, maxWidth: maxWidth))
    }
}
