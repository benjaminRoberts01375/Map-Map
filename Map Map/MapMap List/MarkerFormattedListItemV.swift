//
//  MarkerFormattedListItem.swift
//  Map Map
//
//  Created by Ben Roberts on 12/4/23.
//

import MapKit
import SwiftUI

struct MarkerFormattedListItemV: View {
    @EnvironmentObject var backgroundMapDetails: BackgroundMapDetailsM
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var marker: Marker
    
    var body: some View {
        Button {
            let distance: Double = 6000
            withAnimation {
                backgroundMapDetails.mapCamera = .camera(MapCamera(centerCoordinate: marker.coordinates, distance: distance, heading: -(marker.lockRotationAngleDouble ?? 0)))
            }
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
