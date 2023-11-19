//
//  AddMarkerV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/19/23.
//

import SwiftUI

struct MapButtonV: ViewModifier {
    let size: CGFloat = 45
    func body(content: Content) -> some View {
        content
            .scaledToFit()
            .frame(width: size, height: size)
            .background(.thickMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

extension View {
    func mapButton() -> some View {
        modifier(MapButtonV())
    }
}
