//
//  SmalListItemV.swift
//  Map Map
//
//  Created by Ben Roberts on 3/17/24.
//

import SwiftUI

struct SmallListItemV<ItemType: ListItem>: View {
    /// Item to list.
    @ObservedObject var listItem: ItemType
    /// Size of the Marker within the list.
    private let iconSize: CGFloat = 30
    
    var body: some View {
        HStack(spacing: 0) {
            AnyView(listItem.thumbnail)
            VStack {
                Text(listItem.displayName)
                DisplayCoordinatesV(coordinates: listItem.coordinates)
            }
            Spacer(minLength: 0)
        }
        .opacity(listItem.shown ? 1 : 0.5)
    }
}
