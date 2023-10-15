//
//  MapDetailsM.swift
//  Map Map
//
//  Created by Ben Roberts on 10/14/23.
//

import MapKit
import SwiftUI

final class MapDetailsM: ObservableObject {
    @Published public var position: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @Published public var scale: Double = 1
    @Published public var rotation: Angle = .zero
}
