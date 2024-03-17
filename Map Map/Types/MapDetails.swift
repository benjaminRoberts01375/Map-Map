//
//  MapDetailsM.swift
//  Map Map
//
//  Created by Ben Roberts on 10/14/23.
//

import MapKit
import SwiftUI

@Observable
/// Details about the map being plotted on.
final class MapDetailsM {
    /// Controller for preventing or allowing interaction of the map
    public var allowsInteraction: Bool = true
    /// A corrected version of the map's rotation.
    public var userRotation: Angle { Angle(degrees: abs(self.mapCamera.heading)) }
    /// The live camera for the map
    public var liveMapController: MapCameraPosition = .userLocation(fallback: .automatic)
    /// Current camera for the map.
    public var mapCamera: MapCamera = MapCamera(
        MKMapCamera(
            lookingAtCenter: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            fromDistance: 0,
            pitch: 0,
            heading: 0
        )
    )
    /// Map Proxy for this map.
    public var mapProxy: MapProxy?
    /// Current region for the map.
    public var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: .zero, longitude: .zero),
        span: MKCoordinateSpan(latitudeDelta: .zero, longitudeDelta: .zero)
    )
    
    /// Set the rotation of the map with animation.
    /// - Parameter newRotation: Rotation to set to
    func setMapRotation(newRotation: CGFloat) {
        let camera = MapCamera(centerCoordinate: self.region.center, distance: self.mapCamera.distance, heading: newRotation)
        withAnimation {
            liveMapController = MapCameraPosition.camera(camera)
        }
    }
    
    /// Move the map camera to cover the specified item.
    func moveMapCameraTo(item: MapDisplayable) {
        withAnimation {
            switch item.cameraAlignment {
            case .distance(let distance):
                liveMapController = .camera(MapCamera(centerCoordinate: item.coordinate, distance: distance, heading: item.heading))
            case .span(let span):
                liveMapController = .region(MKCoordinateRegion(center: item.coordinate, span: span))
            }
        }
    }
    
    /// A simple wrapper to prevent the map from following the user's loc and rot.
    func preventFollowingUser() { self.liveMapController = .region(self.region) }
    
    /// Quickly tell the background map to follow the user.
    /// - Parameter followRotation: Bool to track rotation. Default is false.
    func followUser(followRotation: Bool = false) {
        liveMapController = .userLocation(followsHeading: followRotation, fallback: .automatic)
    }
    
    /// Allow easy jumping to a specific coordinate on the map.
    /// - Parameter coordinate: Coordinate to jump to.
    func jumpTo(coordinate: CLLocationCoordinate2D) {
        liveMapController = .region(MKCoordinateRegion(center: coordinate, span: region.span))
    }
}
