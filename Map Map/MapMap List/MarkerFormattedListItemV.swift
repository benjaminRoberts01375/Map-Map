//
//  MarkerFormattedListItem.swift
//  Map Map
//
//  Created by Ben Roberts on 12/4/23.
//

import MapKit
import SwiftUI

/// Create a fully interactive Marker list item.
struct MarkerFormattedListItemV: View {
    /// Information about the background map being plotted on.
    @Environment(BackgroundMapDetailsM.self) private var backgroundMapDetails
    /// Current color scheme. Ex. Dark/Light mode.
    @Environment(\.colorScheme) private var colorScheme
    /// Marker the list item is about.
    @ObservedObject var marker: Marker
    
    var body: some View {
        Button {
            backgroundMapDetails.moveMapCameraTo(marker: marker)
        } label: {
            MarkerListItemV(marker: marker)
                .padding([.trailing, .top, .bottom], 5)
                .padding(.leading)
        }
        .buttonStyle(.plain)
        .background(colorScheme == .dark ? .gray20 : Color.white)
        .contextMenu { MarkerContextMenuV(marker: marker) }
        Divider()
    }
}
