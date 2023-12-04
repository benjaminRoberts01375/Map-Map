//
//  CombineMarkerListItemsV.swift
//  Map Map
//
//  Created by Ben Roberts on 12/3/23.
//

import SwiftUI

struct CombineMarkerListItemsV: View {
    @FetchRequest(sortDescriptors: []) var markers: FetchedResults<Marker>
    @EnvironmentObject var backgroundMapDetails: BackgroundMapDetailsM
    @Environment(\.colorScheme) var colorScheme
    let mapMap: FetchedResults<MapMap>.Element
    
    var body: some View {
        VStack {
            ForEach(Array(mapMap.formattedMarkers)) { marker in
                Button {
                    let distance: Double = 6000
                    withAnimation {
                        backgroundMapDetails.mapCamera = .camera(MapCamera(centerCoordinate: marker.coordinates, distance: distance, heading: -(marker.lockRotationAngleDouble ?? 0)))
                    }
                } label: {
                    MarkerListItemV(marker: marker)
                }
                .buttonStyle(.plain)
                .background(colorScheme == .dark ? .gray20 : Color.white)
                .contextMenu { MarkerContextMenuV(marker: marker) }
                Divider()
            }
        }
    }
}

