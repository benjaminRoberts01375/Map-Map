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
    /// Information about the map being plotted on.
    @Environment(MapDetailsM.self) private var mapDetails
    /// All available MapMaps.
    @FetchRequest(sortDescriptors: []) private var mapMaps: FetchedResults<MapMap>
    /// All available Markers.
    @FetchRequest(sortDescriptors: []) private var markers: FetchedResults<Marker>
    /// All available GPSMaps.
    @FetchRequest(sortDescriptors: []) private var gpsMaps: FetchedResults<GPSMap>
    /// Current Core Data managed object context.
    @Environment(\.managedObjectContext) private var moc
    
    let dividerOffset: CGFloat = 10
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(spacing: 0) {
                ForEach(mapMaps) { mapMap in // MARK: Map Maps
                    LargeListItemV(listItem: mapMap) { mapDetails.moveMapCameraTo(item: mapMap) }
                        .contextMenu { MapMapContextMenuV(mapMap: mapMap) }
                    Divider()
                        .offset(y: dividerOffset)
                    ForEach(mapMap.unwrappedMarkers) { marker in
                        SmallListItemV(listItem: marker) { mapDetails.moveMapCameraTo(item: marker) }
                            .contextMenu { MarkerContextMenuV(marker: marker) }
                        Divider()
                            .offset(y: dividerOffset)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 15))
            
            VStack(spacing: 0) {
                ForEach(gpsMaps) { gpsMap in // MARK: GPS Maps
                    LargeListItemV(listItem: gpsMap) { mapDetails.moveMapCameraTo(item: gpsMap) }
                        .contextMenu { GPSMapContextMenu(gpsMap: gpsMap) }
                    Divider()
                        .offset(y: dividerOffset)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 15))
            
            if markers.contains(where: { $0.formattedMapMaps.isEmpty }) { // MARK: Unsorted Markers
                Text("Unsorted Markers")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                    .padding(.bottom, 5)
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(markers) { marker in
                        SmallListItemV(listItem: marker) { mapDetails.moveMapCameraTo(item: marker) }
                            .contextMenu { MarkerContextMenuV(marker: marker) }
                        Divider()
                            .offset(y: dividerOffset)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 15))
            }
        }
        .ignoresSafeArea()
    }
}
