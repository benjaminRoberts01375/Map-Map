//
//  MapMapListUnsortedMeasurementsV.swift
//  Map Map
//
//  Created by Ben Roberts on 12/17/23.
//

import SwiftUI

/// List of all Markers that are unassociated with a MapMap.
struct MapMapListUnsortedMeasurementsV: View {
    /// All available markers to sort through.
    @FetchRequest(sortDescriptors: []) private var measurements: FetchedResults<MapMeasurement>
    
    var body: some View {
        ForEach(measurements) { measurement in
            if measurement.mapMap == nil { MapMeasurementFormattedListItemV(measurement: measurement) }
        }
    }
}
