//
//  MarkerE.swift
//  Map Map
//
//  Created by Ben Roberts on 3/17/24.
//

import MapKit

extension Marker: MapDisplayable {
    var cameraAlignment: MapCameraAlignment { .distance(6000) }
    
    var heading: Double { -(self.lockRotationAngleDouble ?? 0) }
}
