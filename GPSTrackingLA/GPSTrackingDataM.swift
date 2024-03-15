//
//  GPSTrackingData.swift
//  Map Map
//
//  Created by Ben Roberts on 3/12/24.
//

import ActivityKit
import CoreLocation

struct GPSTrackingAttributes {
    // Static values:
    let gpsMapName: String
}

extension GPSTrackingAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic values:
        /// Current longitude of the user.
        var userLongitude: Double
        /// Current latitude of the user.
        var userLatitude: Double
        /// Seconds elapsed during the creation of this GPS Map.
        var seconds: TimeInterval
        /// Current speed of the user.
        var speed: Measurement<UnitSpeed>
        /// Highest point in the GPS Map.
        var highPoint: Int16
        /// Lowest point in the GPS Map.
        var lowPoint: Int16
        /// Distance the user has traveled during this GPS Map.
        var distance: Int32
        /// Notation used to display user's location.
        var positionNotation: LocationDisplayMode
    }
}
