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
    /// Track if we are currently looking to get background map updates.
    public var authorizationStatus: CLAuthorizationStatus { locationManager.authorizationStatus }
    
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
    
    /// Stop tracking the user's location.
    internal func stopLocationTracking() {
        self.updatesStarted = false
    }
    
    /// Request access to always having the user's location
    internal func requestAlwaysLocation() {
        locationManager.requestAlwaysAuthorization()
    }
    
    /// Start getting the user's location while in the background.
    internal func startAlwaysLocation() {
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
    }
    
    /// End getting the user's location specifically while in the background.
    internal func endAlwaysLocation() {
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.showsBackgroundLocationIndicator = false
    }
}
