//
//  CombineMarkerListItemsV.swift
//  Map Map
//
//  Created by Ben Roberts on 12/3/23.
//

import MapKit
import SwiftUI

struct CombineMarkerListItemsV: View {
    @EnvironmentObject var backgroundMapDetails: BackgroundMapDetailsM
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var mapMap: FetchedResults<MapMap>.Element
    
    var body: some View {
        VStack {
            ForEach(mapMap.formattedMarkers) { marker in
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
    }
}
