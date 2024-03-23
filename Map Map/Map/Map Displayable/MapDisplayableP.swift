//
//  MapDisplayableP.swift
//  Map Map
//
//  Created by Ben Roberts on 3/17/24.
//

import MapKit

/// Protocol to allow for displaying items on the main map.
protocol MapDisplayable {
    /// Center coordinates.
    var coordinate: CLLocationCoordinate2D { get }
    /// Height of camera when centering on map item.
    var cameraAlignment: MapCameraAlignment { get }
    /// Rotation of camera when centered on map item.
    var heading: Double { get }
}

enum MapCameraAlignment {
    case distance(Double)
    case span(MKCoordinateSpan)
}
