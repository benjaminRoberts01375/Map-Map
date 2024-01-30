//
//  LocationDisplayMode.swift
//  Map Map
//
//  Created by Ben Roberts on 11/24/23.
//

import MapKit
import SwiftUI

/// A type dedicated for tracking the location coordinate display type.
public enum LocationDisplayMode: Int {
    /// Display coordinates in degrees (only decimals).
    /// Example: 23.123456º
    case degrees
    /// Display coordinates in degree, minutes, seconds (no decimal).
    /// Example: 25º 22' 1"
    case DMS
}

/// Storage for location display mode in an environment.
private struct LocationDisplayModeKey: EnvironmentKey {
    static var defaultValue: LocationDisplayMode = .degrees
}

/// Getter and setter for location display mode in an environment.
extension EnvironmentValues {
    var locationDisplayMode: LocationDisplayMode {
        get { self[LocationDisplayModeKey.self] }
        set { self[LocationDisplayModeKey.self] = newValue }
    }
}

/// Extension to house functions responsible for formatting location values
extension LocationDisplayMode {
    /// A generic function for generating DMS or degrees for a given location, but lacks hemisphere labels (NSWE).
    /// - Parameter degrees: Degrees to convert.
    /// - Returns: The degrees converted into a string in the correct format.
    func getDirectionlessString(degrees: CLLocationDegrees) -> String {
        let stringFormat = "%.4f"
        
        switch self {
        case .degrees:
            return "\(String(format: stringFormat, abs(degrees)))º"
        case .DMS:
            return "\(abs(degrees.wholeDegrees))º \(degrees.minutes)' \(degrees.seconds)''"
        }
    }
    
    /// Converts latitude into a DMS with hemisphere labels (NSWE).
    /// - Parameter latitude: Latitude to convert.
    /// - Returns: Latitude degrees formatted either into DMS or degrees with labels.
    func degreesToString(latitude: CLLocationDegrees) -> String {
        let directionLabel = latitude < 0 ? "S" : "N"
        return "\(getDirectionlessString(degrees: latitude)) \(directionLabel)"
    }
    
    /// Converts longitude into a DMS with hemisphere labels (NSWE).
    /// - Parameter longitude: longitude  to convert.
    /// - Returns: Longitude degrees formatted either into DMS or degrees with labels.
    func degreesToString(longitude: CLLocationDegrees) -> String {
        let directionLabel = longitude < 0 ? "W" : "E"
        return "\(getDirectionlessString(degrees: longitude)) \(directionLabel)"
    }
}
