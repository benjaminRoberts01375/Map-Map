//
//  MapMapE.swift
//  Map Map
//
//  Created by Ben Roberts on 3/17/24.
//

import MapKit

extension MapMap: MapDisplayable {
    var coordinate: CLLocationCoordinate2D { self.coordinates }
    
    var cameraAlignment: MapCameraAlignment { .distance(self.mapDistance) }
    
    var heading: Double { -self.mapMapRotation }
}
