//
//  MapDetailsM.swift
//  Map Map
//
//  Created by Ben Roberts on 10/14/23.
//

import MapKit
import SwiftUI

final class BackgroundMapDetailsM: ObservableObject {
    @Published public var position: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    public var scale: Double = 1
    public var rotation: Angle = .zero
    @Published public var allowsInteraction: Bool = true
    @Published public var mapCamera: MapCameraPosition = .userLocation(fallback: .automatic)
    public var userRotation: Angle {
        get { Angle(degrees: abs(rotation.degrees)) }
    }
}
