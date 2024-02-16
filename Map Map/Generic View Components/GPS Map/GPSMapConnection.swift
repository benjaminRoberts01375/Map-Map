//
//  GPSMapConnection.swift
//  Map Map
//
//  Created by Ben Roberts on 2/16/24.
//

import MapKit
import SwiftUI

extension GPSMapV {
    /// A basic struct to track the connection between two measurement points.
    internal struct Connection: Identifiable {
        /// Supposed starting position of the connection.
        public var start: GPSMapCoordinate
        /// Supposed ending position of the connection
        public var end: GPSMapCoordinate
        /// ID for Identifiable conformance.
        let id = UUID()
        
        init(_ start: GPSMapCoordinate, _ end: GPSMapCoordinate) {
            self.start = start
            self.end = end
            let startLocation = CLLocation(latitude: start.latitude, longitude: start.longitude)
            let endLocation = CLLocation(latitude: end.latitude, longitude: end.longitude)
        }
    }
}
