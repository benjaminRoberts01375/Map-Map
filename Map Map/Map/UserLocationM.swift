//
//  UserLocationM.swift
//  Map Map
//
//  Created by Ben Roberts on 10/26/23.
//

import CoreLocation
import SwiftUI

@Observable
@MainActor
final class LocationsHandler {
    static let shared = LocationsHandler()
    private let locationManager: CLLocationManager = CLLocationManager()
    
    public var lastLocation = CLLocation()
    private var updatesStarted: Bool = false
    
    func startLocationTracking() {
        Task {
            if locationManager.authorizationStatus == .notDetermined { locationManager.requestWhenInUseAuthorization() }
            self.updatesStarted = true
            let updates = CLLocationUpdate.liveUpdates(.otherNavigation)
            for try await update in updates {
                if !self.updatesStarted { return }  // End location updates by breaking out of the loop.
                if let loc = update.location {
                    withAnimation() {
                        self.lastLocation = loc
                    }
                }
            }
            return
        }
    }
    
    func stopLocationTracking() {
        self.updatesStarted = false
    }
}
