//
//  MarkerFormattedListItem.swift
//  Map Map
//
//  Created by Ben Roberts on 12/4/23.
//

import MapKit
import SwiftUI

struct MarkerFormattedListItemV: View {
    @Environment(BackgroundMapDetailsM.self) private var backgroundMapDetails
    @Environment(\.colorScheme) private var colorScheme
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
