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
