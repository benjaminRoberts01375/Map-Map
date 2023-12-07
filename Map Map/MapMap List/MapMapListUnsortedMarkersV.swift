//
//  MapMapListUnsortedMarkersV.swift
//  Map Map
//
//  Created by Ben Roberts on 12/4/23.
//

import SwiftUI

/// List of all Markers that are unassociated with a MapMap.
struct MapMapListUnsortedMarkersV: View {
    /// All available markers to sort through.
    @FetchRequest(sortDescriptors: []) private var markers: FetchedResults<Marker>
    
    var body: some View {
        ForEach(markers) { marker in
            if marker.formattedMapMaps.isEmpty {
                MarkerFormattedListItemV(marker: marker)
            }
        }
    }
}
