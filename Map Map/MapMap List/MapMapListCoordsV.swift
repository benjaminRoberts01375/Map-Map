//
//  MapMapListCoordsV.swift
//  Map Map
//
//  Created by Ben Roberts on 12/3/23.
//

import MapKit
import SwiftUI

struct MapMapListCoordsV: View {
    @Environment(\.locationDisplayMode) var displayType
    let coordinates: CLLocationCoordinate2D
    
    var body: some View {
        ViewThatFits {
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
