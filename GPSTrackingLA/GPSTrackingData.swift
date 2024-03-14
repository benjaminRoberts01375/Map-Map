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
        var userLongitude: Double
        var userLatitude: Double
        var seconds: TimeInterval
        var speed: Measurement<UnitSpeed>
        var highPoint: Int16
        var lowPoint: Int16
        var distance: Int32
    }
}
