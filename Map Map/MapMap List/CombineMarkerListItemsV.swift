//
//  CombineMarkerListItemsV.swift
//  Map Map
//
//  Created by Ben Roberts on 12/3/23.
//

import MapKit
import SwiftUI

struct CombineMarkerListItemsV: View {
    @ObservedObject var mapMap: FetchedResults<MapMap>.Element
    
    var body: some View {
        VStack {
            ForEach(mapMap.formattedMarkers) { marker in
                MarkerFormattedListItemV(marker: marker)
            }
        }
    }
}
