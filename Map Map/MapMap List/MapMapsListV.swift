//
//  MapListV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/8/23.
//

import MapKit
import SwiftUI

/// List of all MapMaps and Markers
struct MapMapList: View {
    /// Information about the background map being plotted on.
    @Environment(BackgroundMapDetailsM.self) private var backgroundMapDetails
    /// All available MapMaps.
    @FetchRequest(sortDescriptors: []) private var mapMaps: FetchedResults<MapMap>
    /// All available Markers.
    @FetchRequest(sortDescriptors: []) private var markers: FetchedResults<Marker>
    /// All available Map Measurements.
    @FetchRequest(sortDescriptors: []) private var measurements: FetchedResults<MapMeasurementCoordinate>
    /// Current Core Data managed object context.
    @Environment(\.managedObjectContext) private var moc
    /// Current color scheme. Ex. Dark or Light mode.
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 0) {
                ForEach(mapMaps) { mapMap in
                    Button(action: {
                        backgroundMapDetails.moveMapCameraTo(mapMap: mapMap)
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
            
            if markers.contains(where: { $0.formattedMapMaps.isEmpty }) {
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
                .padding(.bottom)
            }
        }
        .ignoresSafeArea()
    }
}
