//
//  CombineMapMeasurementListItemsV.swift
//  Map Map
//
//  Created by Ben Roberts on 12/17/23.
//

import SwiftUI

/// Render all MapMap formatted list items for a single MapMap.
struct CombineMapMeasurementListItemsV: View {
    /// MapMap to render Markers from.
    @ObservedObject var mapMap: FetchedResults<MapMap>.Element
    
    var body: some View {
        VStack {
            ForEach(mapMap.formattedMeasurements) { measurement in
                MapMeasurementFormattedListItemV(measurement: measurement)
            }
        }
        .padding(.top, 7)
    }
}
