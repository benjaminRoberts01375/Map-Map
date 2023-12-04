//
//  MapMapListUnsortedMarkersV.swift
//  Map Map
//
//  Created by Ben Roberts on 12/4/23.
//

import SwiftUI

struct MapMapListUnsortedMarkersV: View {
    @FetchRequest(sortDescriptors: []) var markers: FetchedResults<Marker>
    
    var body: some View {
        ForEach(markers) { marker in
            if marker.formattedMapMaps.isEmpty {
                MarkerFormattedListItemV(marker: marker)
            }
        }
    }
}
