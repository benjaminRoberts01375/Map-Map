//
//  CombineMarkerListItemsV.swift
//  Map Map
//
//  Created by Ben Roberts on 12/3/23.
//

import MapKit
import SwiftUI

/// Render all MapMap formatted list items for a single MapMap.
struct CombineMarkerListItemsV: View {
    /// MapMap to render Markers from.
    @ObservedObject var mapMap: FetchedResults<MapMap>.Element
    
    var body: some View {
        VStack {
            ForEach(mapMap.formattedMarkers) { marker in
                MarkerFormattedListItemV(marker: marker)
            }
        }
        .padding(.top, 7)
    }
}
