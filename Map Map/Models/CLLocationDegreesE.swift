//
//  CLLocationCoordinate2DE.swift
//  Map Map
//
//  Created by Ben Roberts on 10/22/23.
//

import MapKit

extension CLLocationDegrees {
    var wholeDegrees: Int {
        get {
            return Int(self)
        }
    }
    
    var minutes: Int {
        get {
            return abs(Int(self.truncatingRemainder(dividingBy: 1) * 60))
        }
    }
    
    var seconds: Int {
        get {
            let completeMinutes = self.truncatingRemainder(dividingBy: 1) * 60
            return abs(Int(completeMinutes.truncatingRemainder(dividingBy: 1) * 60))
        }
    }
}
