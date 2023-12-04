//
//  CLLocationCoordinate2D.swift
//  Map Map
//
//  Created by Ben Roberts on 11/19/23.
//

import MapKit

extension CLLocationCoordinate2D: Comparable, Equatable {
    public static func < (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.longitude + lhs.latitude < rhs.longitude + rhs.latitude
    }
    
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
