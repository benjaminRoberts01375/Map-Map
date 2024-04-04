//
//  HUDContextMenuV.swift
//  Map Map
//
//  Created by Ben Roberts on 4/4/24.
//

import MapKit
import SwiftUI

struct HUDContextMenuV: View {
    /// Information about the map.
    @Environment(MapDetailsM.self) private var mapDetails
    /// How to display coordinates on screen.
    @AppStorage(UserDefaults.kCoordinateDisplayType) var locationDisplayType = UserDefaults.dCoordinateDisplayType
    /// Control if the satellite map is shown.
    @AppStorage(UserDefaults.kShowSatelliteMap) var mapType = UserDefaults.dShowSatelliteMap
    
    var body: some View {
        Button {
            openCurrentLocationInMaps()
        } label: {
            Label("Open in Maps", systemImage: "map.fill")
        }
        Button {
            switch locationDisplayType {
            case .degrees:
                locationDisplayType = .DMS
            case .DMS:
                locationDisplayType = .degrees
            }
        } label: {
            switch locationDisplayType {
            case .degrees:
                Label("Show Degrees, Minutes, Seconds", systemImage: "clock.fill")
            case .DMS:
                Label("Show Degrees", systemImage: "numbersign")
            }
        }
        Button {
            mapType.toggle()
        } label: {
            if mapType { Label("Show Standard Map", systemImage: "scribble.variable") }
            else { Label("Show Satellite Map", systemImage: "tree.fill") }
        }
    }
    
    /// Allows for opening the map's current location in Apple Maps.
    private func openCurrentLocationInMaps() {
        let placemark = MKPlacemark(coordinate: mapDetails.region.center)
        let mapItem = MKMapItem(placemark: placemark)
        let launchOptions: [String : Any] = [
            MKLaunchOptionsMapCenterKey: mapDetails.region.center,
            MKLaunchOptionsMapSpanKey: mapDetails.region.span
        ]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
}
