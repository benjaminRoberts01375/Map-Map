//
//  UserDefaults.swift
//  Map Map
//
//  Created by Ben Roberts on 1/29/24.
//

import SwiftUI

extension UserDefaults {
    /// Default value for the User Defaults entry of the coordinate display type.
    static let dCoordinateDisplayType: LocationDisplayMode = .degrees
    /// Key for the User Defaults entry for coordinate display type.
    static let kCoordinateDisplayType: String = "coordinateDisplayType"
    /// Default value for the User Defaults entry of the marker chirp control.
    static let dAudioAlerts: Bool = false
    /// Key for the User Defaults entry for the marker chirp control.
    static let kAudioAlerts: String = "audioAlerts"
}
