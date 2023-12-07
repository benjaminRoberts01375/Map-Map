//
//  MapMapListCoordsV.swift
//  Map Map
//
//  Created by Ben Roberts on 12/3/23.
//

import MapKit
import SwiftUI

/// Handle layout of coordinates depending how much horizontal space is available to this view.
struct MapMapListCoordsV: View {
    /// Coordinate display type.
    @Environment(\.locationDisplayMode) var displayType
    /// Coordinates to display.
    let coordinates: CLLocationCoordinate2D
    
    var body: some View {
        ViewThatFits(in: .horizontal) {
            VStack(alignment: .leading) {
                Text("Latitude: ") +
                Text(displayType.degreesToString(latitude: coordinates.latitude))
                    .fontWidth(.condensed)
                Text("Longitude: ") +
                Text(displayType.degreesToString(longitude: coordinates.longitude))
                    .fontWidth(.condensed)
            }
            VStack(alignment: .leading) {
                Text("Latitude: ")
                Text(displayType.degreesToString(latitude: coordinates.latitude))
                    .fontWidth(.condensed)
                Text("Longitude: ")
                Text(displayType.degreesToString(longitude: coordinates.longitude))
                    .fontWidth(.condensed)
            }
        }
        .foregroundStyle(.secondary)
    }
}
