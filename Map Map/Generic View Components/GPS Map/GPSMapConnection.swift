//
//  GPSMapConnection.swift
//  Map Map
//
//  Created by Ben Roberts on 2/16/24.
//

import MapKit
import SwiftUI

extension GPSMapBranchV {
    /// A basic struct to track the connection between two measurement points.
    internal struct Connection: Identifiable {
        /// Supposed starting position of the connection.
        public var start: CGPoint
        /// Supposed ending position of the connection
        public var end: CGPoint
        /// ID for Identifiable conformance.
        let id = UUID()
    }
}
