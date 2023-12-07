//
//  BigButtonV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/15/23.
//

import SwiftUI

/// Format the label of a button to appear as a large button for the bottom drawers.
struct BigButton: ViewModifier {
    let background: Color
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(.white)
            .frame(width: 90, height: 40)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

extension View {
    /// Format the label of a button to appear as a large button for the bottom drawers.
    func bigButton(backgroundColor background: Color) -> some View {
        return modifier(BigButton(background: background))
    }
}
