//
//  CLLocationCoordinate2DE.swift
//  Map Map
//
//  Created by Ben Roberts on 10/22/23.
//

import MapKit

/// Simple formatting of CLLocationDegrees
extension CLLocationDegrees {
    /// Whole number of degrees.
    var wholeDegrees: Int {
        return Int(self)
    }
    
    /// Minutes calculation of self.
    var minutes: Int {
        return abs(Int(self.truncatingRemainder(dividingBy: 1) * 60))
    }
    
    /// Seconds calculation of self.
    var seconds: Int {
        let completeMinutes = self.truncatingRemainder(dividingBy: 1) * 60
        return abs(Int(completeMinutes.truncatingRemainder(dividingBy: 1) * 60))
    }
}
