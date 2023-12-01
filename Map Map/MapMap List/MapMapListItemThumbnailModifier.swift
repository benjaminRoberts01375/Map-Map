//
//  MapListItemThumbnailModifier.swift
//  Map Map
//
//  Created by Ben Roberts on 10/23/23.
//

import SwiftUI

struct MapMapListItemThumbnail: ViewModifier {
    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .frame(minWidth: 100, idealWidth: 100, maxWidth: 100, minHeight: 50, maxHeight: 100)
            .background(.thickMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

extension View {
    func mapMapListItemThumbnail() -> some View {
        modifier(MapMapListItemThumbnail())
    }
}
