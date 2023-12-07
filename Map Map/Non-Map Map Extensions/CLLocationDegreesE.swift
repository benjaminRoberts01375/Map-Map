//
//  CLLocationCoordinate2DE.swift
//  Map Map
//
//  Created by Ben Roberts on 10/22/23.
//

import MapKit

extension CLLocationDegrees {
    var wholeDegrees: Int {
        return Int(self)
    }
    
    var minutes: Int {
        return abs(Int(self.truncatingRemainder(dividingBy: 1) * 60))
    }
    
    var seconds: Int {
        let completeMinutes = self.truncatingRemainder(dividingBy: 1) * 60
        return abs(Int(completeMinutes.truncatingRemainder(dividingBy: 1) * 60))
    }
}
