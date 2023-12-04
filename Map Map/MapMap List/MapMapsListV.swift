//
//  MapListV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/8/23.
//

import MapKit
import SwiftUI

struct MapMapList: View {
    @EnvironmentObject var backgroundMapDetails: BackgroundMapDetailsM
    @FetchRequest(sortDescriptors: []) var mapMaps: FetchedResults<MapMap>
    @Environment(\.managedObjectContext) var moc
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 0) {
                ForEach(mapMaps) { mapMap in
                    Button(action: {
                        withAnimation {
                            backgroundMapDetails.mapCamera = .camera(MapCamera(centerCoordinate: mapMap.coordinates, distance: mapMap.mapDistance, heading: -mapMap.mapMapRotation))
                        }
                    }, label: {
                        MapMapListItemV(mapMap: mapMap)
                            .padding()
                    })
                    .buttonStyle(.plain)
                    .background(colorScheme == .dark ? .gray20 : Color.white)
                    .contextMenu { MapMapContextMenuV(mapMap: mapMap) }
                    Divider()
                    if !mapMap.formattedMarkers.isEmpty {
                        CombineMarkerListItemsV(mapMap: mapMap)
                    }
                }
            }
            .background(colorScheme == .dark ? .gray20 : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            
            Text("Unsorted Markers")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)
                .padding(.bottom, 5)
            VStack {
                MapMapListUnsortedMarkersV()
            }
            .padding(.top, 5)
            .background(colorScheme == .dark ? .gray20 : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .ignoresSafeArea()
    }
}
