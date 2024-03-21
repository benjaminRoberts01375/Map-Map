//
//  LargeListItemV.swift
//  Map Map
//
//  Created by Ben Roberts on 3/17/24.
//

import SwiftUI

struct LargeListItemV<ItemType: ListItem>: View {
    /// Current color scheme. Ex. Dark or Light mode.
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var listItem: ItemType
    private let thumbnailSize: CGFloat = 100
    private let cornerRadius: CGFloat = 10
    var action: () -> Void
    
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
        }
        .buttonStyle(.plain)
        .opacity(listItem.shown ? 1 : 0.5)
        .padding(.top, 5)
        .padding(.horizontal)
        .padding(.bottom)
        .background(colorScheme == .dark ? .gray20 : Color.white)
    }
}
