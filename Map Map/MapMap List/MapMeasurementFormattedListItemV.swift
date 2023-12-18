//
//  MeasurementFormattedListItemV.swift
//  Map Map
//
//  Created by Ben Roberts on 12/17/23.
//

import SwiftUI

struct MapMeasurementFormattedListItemV: View {
    /// Information about the background map being plotted on.
    @Environment(BackgroundMapDetailsM.self) private var backgroundMapDetails
    /// Current color scheme. Ex. Dark/Light mode.
    @Environment(\.colorScheme) private var colorScheme
    /// Marker the list item is about.
    @ObservedObject var measurement: MapMeasurement
    
    var body: some View {
        Button {
            backgroundMapDetails.moveMapCameraTo(measurement: measurement)
        } label: {
            MapMeasurementListItemV(measurement: measurement)
                .padding([.trailing, .top, .bottom], 5)
                .padding(.leading)
        }
        .buttonStyle(.plain)
        .background(colorScheme == .dark ? .gray20 : Color.white)
        .contextMenu { MapMeasurementContextMenuV(measurement: measurement) }
        Divider()
    }
}
