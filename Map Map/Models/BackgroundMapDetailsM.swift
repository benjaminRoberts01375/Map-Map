//
//  MapDetailsM.swift
//  Map Map
//
//  Created by Ben Roberts on 10/14/23.
//

import MapKit
import SwiftUI

@Observable
final class BackgroundMapDetailsM {
    /// The last updated position of the map.
    public var position: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    /// The last updated "scale" of the map, which is determined by calculating 1 divided by the mapCamera distance.
    @ObservationIgnored
    public var scale: Double = 1
    /// The last updated rotation of the map.
    @ObservationIgnored
    public var rotation: Angle = .zero
    /// Controller for preventing or allowing interaction of the background map
    public var allowsInteraction: Bool = true
    /// The last updated span of the map, providing how much map is being shown at the current moment.
    @ObservationIgnored
    public var span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 0)
    /// The live camera for the map
    public var mapCamera: MapCameraPosition = .userLocation(fallback: .automatic)
    /// A corrected version of the background map's rotation.
    public var userRotation: Angle {
        Angle(degrees: abs(rotation.degrees))
    }
    
    func setMapRotation(newRotation: CGFloat) {
        let camera = MapCamera(centerCoordinate: position, distance: 1 / scale, heading: newRotation)
        withAnimation {
            mapCamera = MapCameraPosition.camera(camera)
        }
    }
    
    func moveMapCameraTo(marker: Marker) {
        withAnimation {
            let distance: Double = 6000
            mapCamera = .camera(
                MapCamera(
                    centerCoordinate: marker.coordinates,
                    distance: distance,
                    heading: -(marker.lockRotationAngleDouble ?? 0)
                )
            )
        }
    }
    
    func moveMapCameraTo(mapMap: MapMap) {
        withAnimation {
            mapCamera = .camera(
                MapCamera(
                    centerCoordinate: mapMap.coordinates,
                    distance: mapMap.mapDistance,
                    heading: -mapMap.mapMapRotation
                )
            )
        }
    }
}
