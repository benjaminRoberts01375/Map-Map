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
    }
}
