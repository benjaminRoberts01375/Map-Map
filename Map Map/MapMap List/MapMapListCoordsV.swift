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
    @AppStorage(UserDefaults.kCoordinateDisplayType) var locationDisplayType = UserDefaults.dCoordinateDisplayType
    /// Coordinates to display.
    let coordinates: CLLocationCoordinate2D
    
    var body: some View {
        ViewThatFits(in: .horizontal) {
            VStack(alignment: .leading) {
                Text("Latitude: ") +
                Text(locationDisplayType.degreesToString(latitude: coordinates.latitude))
                    .fontWidth(.condensed)
                Text("Longitude: ") +
                Text(locationDisplayType.degreesToString(longitude: coordinates.longitude))
                    .fontWidth(.condensed)
            }
            VStack(alignment: .leading) {
                Text("Latitude: ")
                Text(locationDisplayType.degreesToString(latitude: coordinates.latitude))
                    .fontWidth(.condensed)
                Text("Longitude: ")
                Text(locationDisplayType.degreesToString(longitude: coordinates.longitude))
                    .fontWidth(.condensed)
            }
        }
        .foregroundStyle(.secondary)
    }
}
