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
    public var position: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @ObservationIgnored
    public var scale: Double = 1
    @ObservationIgnored
    public var rotation: Angle = .zero
    public var allowsInteraction: Bool = true
    @ObservationIgnored
    public var span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 0)
    public var mapCamera: MapCameraPosition = .userLocation(fallback: .automatic)
    public var userRotation: Angle {
        get { Angle(degrees: abs(rotation.degrees)) }
    }
    
    func setMapRotation(newRotation: CGFloat) {
        let camera = MapCamera(centerCoordinate: position, distance: 1 / scale, heading: newRotation)
        withAnimation {
            mapCamera = MapCameraPosition.camera(camera)
        }
    }
}
