//
//  MapUI.swift
//  Map Map
//
//  Created by Ben Roberts on 9/13/23.
//

import MapKit
import SwiftUI

struct MapMap {
    /// Default displayed radius of the map
    public let defaultRadius: Double
    /// Default location is centered on Champlain College
    public let defaultLocation: CLLocationCoordinate2D
    /// Region for being centered on Champlain College
    public let defaultRegion: MKCoordinateRegion
    /// Keeps track of the user's location
    /// - important: Needs to be outside of the makeUIView because of a callback from the UserLocation class.
    var userLocation: UserLocation
    /// Where the map is currently displaying
    @State var region: MKCoordinateRegion
    
    init() {
        self.defaultRadius = 10000
        self.defaultLocation = CLLocationCoordinate2D(latitude: 44.47301, longitude: -73.20390)
        self.defaultRegion = MKCoordinateRegion(center: defaultLocation, latitudinalMeters: defaultRadius, longitudinalMeters: defaultRadius)
        self.region = self.defaultRegion
        self.userLocation = UserLocation()
    }
}
