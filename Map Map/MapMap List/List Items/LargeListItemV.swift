//
//  LargeListItemV.swift
//  Map Map
//
//  Created by Ben Roberts on 3/17/24.
//

import SwiftUI

struct LargeListItemV<ItemType: ListItem, V: View>: View {
    @ObservedObject var listItem: ItemType
    private let thumbnailSize: CGFloat = 100
    private let cornerRadius: CGFloat = 10
    var action: () -> Void
    var contextMenu: V
    
    var body: some View {
        Button { 
            action()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    Text(listItem.displayName)
                        .font(.title3)
                        .padding(.bottom, 7)
                    Spacer(minLength: 0)
                }
                HStack(spacing: 0) {
                    AnyView(listItem.thumbnail)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius / 2))
                        .frame(
                            minWidth: thumbnailSize,
                            idealWidth: thumbnailSize,
                            maxWidth: thumbnailSize,
                            minHeight: thumbnailSize / 2,
                            maxHeight: thumbnailSize
                        )
                        .background(.thickMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                        .padding(.trailing)
                    DisplayCoordinatesV(coordinates: listItem.coordinate)
                    Spacer(minLength: 0)
                }
            }
            .contextMenu { contextMenu }
            .opacity(listItem.shown ? 1 : 0.5)
        }
    }
}
