//
//  GPSMapE.swift
//  Map Map
//
//  Created by Ben Roberts on 3/17/24.
//

import MapKit

extension GPSMap: MapDisplayable {
    var cameraAlignment: MapCameraAlignment {
        .span(MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta))
    }
    
    var heading: Double { 0 }
}
