//
//  MapMeasurement.swift
//  Map Map
//
//  Created by Ben Roberts on 12/17/23.
//

import SwiftUI

struct MapMeasurementContextMenuV: View {
    @ObservedObject var measurement: FetchedResults<MapMeasurement>.Element
    /// Details about the background map being plotted on.
    @Environment(BackgroundMapDetailsM.self) private var backgroundMapDetails
    @Environment(\.managedObjectContext) private var moc
    
    var body: some View {
        Button(role: .destructive) {
            moc.delete(measurement)
            try? moc.save()
        } label: {
            Label("Delete Measurement", systemImage: "trash.fill")
        }
        
        Button {
            backgroundMapDetails.moveMapCameraTo(measurement: measurement)
            measurement.isEditing = true
        } label: {
            Label("Edit Map Measurement", systemImage: "pencil")
        }
    }
}
