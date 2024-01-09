//
//  MapDetailsM.swift
//  Map Map
//
//  Created by Ben Roberts on 10/14/23.
//

import MapKit
import SwiftUI

@Observable
/// Details about the background map being plotted on.
final class BackgroundMapDetailsM {
    /// Controller for preventing or allowing interaction of the background map
    public var allowsInteraction: Bool = true
    /// A corrected version of the background map's rotation.
    public var userRotation: Angle { Angle(degrees: abs(self.mapCamera.heading)) }
    /// The live camera for the map
    public var liveMapController: MapCameraPosition = .userLocation(fallback: .automatic)
    /// Current camera for the background map.
    public var mapCamera: MapCamera = MapCamera(
        MKMapCamera(
            lookingAtCenter: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            fromDistance: 0,
            pitch: 0,
            heading: 0
        )
    )
    /// Current region for the background map.
    public var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: .zero, longitude: .zero),
        span: MKCoordinateSpan(latitudeDelta: .zero, longitudeDelta: .zero)
    )
    
    /// Set the rotation of the background map with animation.
    /// - Parameter newRotation: Rotation to set to
    func setMapRotation(newRotation: CGFloat) {
        let camera = MapCamera(centerCoordinate: self.region.center, distance: self.mapCamera.distance, heading: newRotation)
        withAnimation {
            liveMapController = MapCameraPosition.camera(camera)
        }
    }
    
    /// Translate the background map to the desired marker location and scale.
    /// - Parameter marker: Marker to move to.
    func moveMapCameraTo(marker: Marker) {
        withAnimation {
            let distance: Double = 6000
            liveMapController = .camera(
                MapCamera(
                    centerCoordinate: marker.coordinates,
                    distance: distance,
                    heading: -(marker.lockRotationAngleDouble ?? 0)
                )
            )
        }
    }
    
    /// Translate the background map to the desired MapMap location and scale.
    /// - Parameter mapMap: MapMap to move to.
    func moveMapCameraTo(mapMap: MapMap) {
        withAnimation {
            liveMapController = .camera(
                MapCamera(
                    centerCoordinate: mapMap.coordinates,
                    distance: mapMap.mapDistance,
                    heading: -mapMap.mapMapRotation
                )
            )
        }
    }
    
    /// A simple wrapper to prevent the background map from following the user's loc and rot.
    func preventFollowingUser() { self.liveMapController = .region(self.region) }
}
