//
//  MapConnection.swift
//  Map Map
//
//  Created by Ben Roberts on 12/27/23.
//

import MapKit
import SwiftUI

extension MapPointsV {
    /// A basic struct to track the connection between two measurement points.
    internal struct Connection: Identifiable {
        /// Supposed starting position of the connection.
        public var start: MapMeasurementCoordinate
        /// Supposed ending position of the connection
        public var end: MapMeasurementCoordinate
        /// Distance between the start and end position.
        public var distance: Measurement<UnitLength>
        /// ID for Identifiable conformance.
        let id = UUID()
        
        init(_ start: MapMeasurementCoordinate, _ end: MapMeasurementCoordinate) {
            self.start = start
            self.end = end
            let startLocation = CLLocation(latitude: start.latitude, longitude: start.longitude)
            let endLocation = CLLocation(latitude: end.latitude, longitude: end.longitude)
            self.distance = Measurement(value: endLocation.distance(from: startLocation), unit: .meters)
        }
    }
}
