//
//  MapDisplayableP.swift
//  Map Map
//
//  Created by Ben Roberts on 3/17/24.
//

import MapKit

protocol MapDisplayable {
    var coordinate: CLLocationCoordinate2D { get }
    var cameraAlignment: MapCameraAlignment { get }
    var heading: Double? { get }
}

enum MapCameraAlignment {
    case distance(Double)
    case span(MKCoordinateSpan)
}
