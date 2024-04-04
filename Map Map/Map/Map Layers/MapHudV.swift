//
//  MapCenterV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/18/23.
//

import MapKit
import SwiftUI

/// HUD to display information about the map being plotted on.
struct MapHudV: View {
    /// Information about the map.
    @Environment(MapDetailsM.self) private var mapDetails
    /// How to display coordinates on screen.
    @AppStorage(UserDefaults.kCoordinateDisplayType) var locationDisplayType = UserDefaults.dCoordinateDisplayType
    /// Tracker for showing the heading.
    @State private var showHeading: Bool = false
    /// GPS user location.
    @State private var locationsHandler = LocationsHandler.shared
    /// Control decimals when converted to a string.
    private let stringFormat: String = "%.4f"
    
    var tap: some Gesture {
       TapGesture()
            .onEnded { _ in
                mapDetails.setMapRotation(newRotation: 0)
            }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading) {
                Text("Latitude: ") +
                Text(locationDisplayType.degreesToString(latitude: mapDetails.region.center.latitude))
                    .fontWidth(.condensed)
                
                Text("Longitude: ") +
                Text(locationDisplayType.degreesToString(longitude: mapDetails.region.center.longitude))
                    .fontWidth(.condensed)
                if showHeading {
                    Text("Heading: ") +
                    Text("\(String(format: stringFormat, mapDetails.userRotation.degrees))º ").fontWidth(.condensed) +
                    Text(determineHeadingLabel())
                }
                Text("Altitude: ") +
                Text(LocationDisplayMode.metersToString(meters: locationsHandler.lastLocation.altitude))
                    .fontWidth(.condensed)
            }
            Spacer(minLength: 0)
        }
        .frame(width: 185)
        .padding([.leading, .vertical], 10)
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 11))
        .contextMenu {
            HUDContextMenuV()
                .onAppear { UseHUDTip().invalidate(reason: .actionPerformed) }
        }
        .onChange(of: mapDetails.mapCamera) { _, update in
            withAnimation {
                showHeading = -update.heading != 0
            }
        }
        .gesture(tap)
        .animation(.easeInOut, value: locationDisplayType)
    }
    
    /// Determine the heading label for the map's current rotation.
    private func determineHeadingLabel() -> String {
        var label = ""
        let shareOfThePie = 67.5
        let quarter: Double = 90
        if mapDetails.userRotation.degrees < shareOfThePie {
            label += "N"
        }
        else if mapDetails.userRotation.degrees.isBetween(min: quarter * 4 - shareOfThePie, max: quarter * 4 + shareOfThePie) {
            label += "N"
        }
        if mapDetails.userRotation.degrees.isBetween(min: quarter * 2 - shareOfThePie, max: quarter * 2 + shareOfThePie) {
            label += "S"
        }
        if mapDetails.userRotation.degrees.isBetween(min: quarter - shareOfThePie, max: quarter + shareOfThePie) {
            label += "E"
        }
        if mapDetails.userRotation.degrees.isBetween(min: quarter * 3 - shareOfThePie, max: quarter * 3 + shareOfThePie) {
            label += "W"
        }
        
        return label
    }
}

struct MapHudV_Previews: PreviewProvider {
    static var previews: some View {
        let mapDetails = MapDetailsM()
        return MapHudV()
            .environment(mapDetails)
    }
}
