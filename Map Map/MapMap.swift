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
    static private let defaultRadius: Double = 10000
    /// Default location is centered on Champlain College
    static public let defaultLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 44.47301, longitude: -73.20390)
    /// Region for being centered on Champlain College
    static public let defaultRegion: MKCoordinateRegion = MKCoordinateRegion(center: defaultLocation, latitudinalMeters: defaultRadius, longitudinalMeters: defaultRadius)
}
