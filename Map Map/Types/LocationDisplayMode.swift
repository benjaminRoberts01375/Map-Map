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
    
    /// Convert meters to the appropriate string.
    /// - Parameter meters: Meters.
    /// - Returns: Meters formatted into the appropriate string.
    static func metersToAltitude(meters: Double) -> String {
        switch Locale.current.measurementSystem {
        case .us:
            if meters > 160 {
                let value = Measurement<UnitLength>(value: meters, unit: .meters).converted(to: .miles).value
                return "\(String(format: "%.1f", value)) mi"
            }
            let value = Measurement<UnitLength>(value: meters, unit: .meters).converted(to: .feet).value
            return "\(Int(value)) ft"
        default:
            if meters > 100 {
                let value = Measurement<UnitLength>(value: meters, unit: .meters).converted(to: .kilometers).value
                return "\(String(format: "%.1f", value)) km"
            }
            let value = Measurement<UnitLength>(value: meters, unit: .meters).value
            return "\(Int(value)) m"
        }
    }
}
