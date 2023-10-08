//
//  UserLocation.swift
//  Map Map
//
//  Created by Ben Roberts on 9/13/23.
//

import MapKit

/// Handle user location permissions
final class UserLocation: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    /// Handles delegating location permission information
    var locationManager: CLLocationManager?
    /// What to do when the user location permission change
    var onAuthorizationChanged: (() -> Void)?
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    /// Fires when the user changes the app's ability to see the current location
    /// - Parameter manager: Handles delegating location permission information
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) { // Permission changed or created
        guard let locationManager = locationManager else { return }
        locationManager.authorizationStatus == .notDetermined ? locationManager.requestWhenInUseAuthorization() : onAuthorizationChanged?() // Ask user for location permission
    }
}
