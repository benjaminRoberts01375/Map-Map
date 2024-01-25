//
//  MapLabelVModifier.swift
//  Map Map
//
//  Created by Ben Roberts on 12/16/23.
//

import SwiftUI

struct MapLabelVModifier: ViewModifier {
    private let shadowRadius: CGFloat = 8
    func body(content: Content) -> some View {
        content
            .shadow(color: .black, radius: shadowRadius)
    }
}

extension View {
    /// Standard modifier for text on the map.
    /// - Returns: Modified view.
    func mapLabel() -> some View {
        modifier(MapLabelVModifier())
    }
}
