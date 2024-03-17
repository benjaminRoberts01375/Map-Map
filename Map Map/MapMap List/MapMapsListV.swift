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
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(mapMaps) { mapMap in // MARK: Map Maps
                LargeListItemV(
                    listItem: mapMap,
                    action: { mapDetails.moveMapCameraTo(item: mapMap) },
                    contextMenu: MapMapContextMenuV(mapMap: mapMap)
                )
                
                ForEach(mapMap.formattedMarkers) { marker in
                    SmallListItemV(
                        listItem: marker,
                        action: { mapDetails.moveMapCameraTo(item: marker) },
                        contextMenu: MarkerContextMenuV(marker: marker)
                    )
                }
            }
            
            ForEach(gpsMaps) { gpsMap in // MARK: GPS Maps
                LargeListItemV(
                    listItem: gpsMap,
                    action: { mapDetails.moveMapCameraTo(item: gpsMap) },
                    contextMenu: GPSMapContextMenu(gpsMap: gpsMap)
                )
            }
            
            if markers.contains(where: { $0.formattedMapMaps.isEmpty }) { // MARK: Unsorted Markers
                Text("Unsorted Markers")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                    .padding(.bottom, 5)
                ForEach(markers) { marker in
                    SmallListItemV(
                        listItem: marker,
                        action: { mapDetails.moveMapCameraTo(item: marker) },
                        contextMenu: MarkerContextMenuV(marker: marker)
                    )
                }
            }
        }
        .ignoresSafeArea()
    }
}
