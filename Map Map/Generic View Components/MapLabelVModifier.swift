//
//  MapLabelVModifier.swift
//  Map Map
//
//  Created by Ben Roberts on 12/16/23.
//

import SwiftUI

struct MapLabelVModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    private let shadowRadius: CGFloat = 8
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(colorScheme == .dark ? .white : .black)
            .shadow(color: colorScheme == .dark ? .black : .white, radius: shadowRadius)
    }
}

extension View {
    /// Standard modifier for text on the map.
    /// - Returns: Modified view.
    func mapLabel() -> some View {
        modifier(MapLabelVModifier())
    }
}
