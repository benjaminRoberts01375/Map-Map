//
//  MeasurementListItemV.swift
//  Map Map
//
//  Created by Ben Roberts on 12/17/23.
//

import SwiftUI

struct MapMeasurementListItemV: View {
    /// Marker to derrive the list item from.
    @ObservedObject var measurement: FetchedResults<MapMeasurement>.Element
    /// How to render coordinates from environment.
    @Environment(\.locationDisplayMode) private var displayType
    /// Size of the Marker within the list.
    private let markerSize: CGFloat = 30
    
    var body: some View {
        HStack(spacing: 0) {
                Image(systemName: "ruler.fill")
                    .frame(width: markerSize)
                    .padding(.trailing)
                VStack(alignment: .leading) {
                    Text("Start")
                    MapMapListCoordsV(coordinates: measurement.startingCoordinates)
                    Text("End")
                    MapMapListCoordsV(coordinates: measurement.endingCoordinates)
                }
            Spacer(minLength: 0)
        }
        .opacity(measurement.mapMap?.shown ?? true ? 1 : 0.5)
    }
}
