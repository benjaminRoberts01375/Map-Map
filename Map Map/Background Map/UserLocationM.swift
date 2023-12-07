//
//  UserLocationM.swift
//  Map Map
//
//  Created by Ben Roberts on 10/26/23.
//

import CoreLocation
import SwiftUI

/// Handle user location updates.
@Observable
@MainActor
final class LocationsHandler {
    /// Setup singleton of the locations handler.
    static let shared = LocationsHandler()
    /// Create a location manager to get the user location.
    private let locationManager: CLLocationManager = CLLocationManager()
    /// The last known location on Earth of the user.
    public var lastLocation = CLLocation()
    /// Track if we're currently getting the user's location.
    private var updatesStarted: Bool = false
    
    internal func startLocationTracking() {
        Task {
            if locationManager.authorizationStatus == .notDetermined { locationManager.requestWhenInUseAuthorization() }
            self.updatesStarted = true
            let updates = CLLocationUpdate.liveUpdates(.otherNavigation)
            for try await update in updates {
                if !self.updatesStarted { return }  // End location updates by breaking out of the loop.
                if let loc = update.location {
                    withAnimation {
                        self.lastLocation = loc
                    }
                }
            }
            return
        }
    }
    
    internal func stopLocationTracking() {
        self.updatesStarted = false
    }
}
