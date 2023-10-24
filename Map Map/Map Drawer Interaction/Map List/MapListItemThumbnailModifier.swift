//
//  MapListItemThumbnailModifier.swift
//  Map Map
//
//  Created by Ben Roberts on 10/23/23.
//

import SwiftUI

struct MapListItemThumbnail: ViewModifier {
    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .frame(width: 100, height: 100)
            .background(.thickMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding()
    }
}

extension View {
    func mapListItemThumbnail() -> some View {
        modifier(MapListItemThumbnail())
    }
}
