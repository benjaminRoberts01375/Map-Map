//
//  SmalListItemV.swift
//  Map Map
//
//  Created by Ben Roberts on 3/17/24.
//

import SwiftUI

struct SmallListItemV<ItemType: ListItem, V: View>: View {
    /// Current color scheme. Ex. Dark or Light mode.
    @Environment(\.colorScheme) private var colorScheme
    /// Item to list.
    @ObservedObject var listItem: ItemType
    /// Size of the Marker within the list.
    private let iconSize: CGFloat = 30
    /// Action for this list item to take when pressed
    var action: () -> Void
    
    var contextMenu: V
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 0) {
                AnyView(listItem.thumbnail)
                VStack {
                    Text(listItem.displayName)
                    DisplayCoordinatesV(coordinates: listItem.coordinate)
                }
                Spacer(minLength: 0)
            }
            .opacity(listItem.shown ? 1 : 0.5)
            .padding(.top, 5)
            .background(colorScheme == .dark ? .gray20 : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .padding(.bottom)
            .contextMenu { contextMenu }
        }
    }
}
