//
//  LocationDisplayMode.swift
//  Map Map
//
//  Created by Ben Roberts on 11/24/23.
//

import MapKit
import SwiftUI

public enum LocationDisplayMode {
    case degrees
    case DMS
}

private struct LocationDisplayModeKey: EnvironmentKey {
    static var defaultValue: LocationDisplayMode = .degrees
}

extension EnvironmentValues {
    var locationDisplayMode: LocationDisplayMode {
        get { self[LocationDisplayModeKey.self] }
        set { self[LocationDisplayModeKey.self] = newValue }
    }
}

extension LocationDisplayMode {
    func getDirectionlessString(degrees: CLLocationDegrees) -> String {
        let stringFormat = "%.4f"
        
        switch self {
        case .degrees:
            return "\(String(format: stringFormat, abs(degrees)))º"
        case .DMS:
            return "\(abs(degrees.wholeDegrees))º \(degrees.minutes)' \(degrees.seconds)''"
        }
    }
    
    func degreesToString(latitude: CLLocationDegrees) -> String {
        let directionLabel = latitude < 0 ? "S" : "N"
        return "\(getDirectionlessString(degrees: latitude)) \(directionLabel)"
    }
    
    func degreesToString(longitude: CLLocationDegrees) -> String {
        let directionLabel = longitude < 0 ? "W" : "E"
        return "\(getDirectionlessString(degrees: longitude)) \(directionLabel)"
    }
}
