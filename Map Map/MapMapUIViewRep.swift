//
//  MapMapUIViewRep.swift
//  Map Map
//
//  Created by Ben Roberts on 9/13/23.
//

import MapKit
import SwiftUI

extension MapMap: UIViewRepresentable {
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        
        // Getting the user's location
        userLocation.setupLocationManager()                         // Get permission from user to show on map
        userLocation.onAuthorizationChanged = {                     // If authorization changed, try to get the user's location. If unable, use defaults.
            region = MKCoordinateRegion(
                center: userLocation.locationManager?.location?.coordinate ?? mapView.centerCoordinate,
                latitudinalMeters: defaultRadius,
                longitudinalMeters: defaultRadius
            )                       // Get the user's region, and if unavailable, fallback to the current one
            mapView.setRegion(region, animated: true)
        }                // If user's preferences change, run this code to set map position accordingly
        mapView.showsUserLocation = true
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) { }
}
