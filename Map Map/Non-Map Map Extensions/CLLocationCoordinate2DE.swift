//
//  CLLocationCoordinate2D.swift
//  Map Map
//
//  Created by Ben Roberts on 11/19/23.
//

import MapKit

extension CLLocationCoordinate2D: Comparable, Equatable {
    /// Enable the Comparable protocol.
    /// - Parameters:
    ///   - lhs: Potentially lesser CLLocationCoordinate2D
    ///   - rhs: Potentially greater CLLocationCoordinate2D
    /// - Returns: Result of adding the latitude and longitude of each CLLocationCoordinate2D and comparing the two sums.
    public static func < (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.longitude + lhs.latitude < rhs.longitude + rhs.latitude
    }
    
    /// Enable the Equatable protocol
    /// - Parameters:
    ///   - lhs: Left CLLocationCoordinate2D
    ///   - rhs: Right CLLocationCoordinate2D
    /// - Returns: Boolean result of checking if both CLLocationCoordinate2D's are equal.
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
