//
//  MapMapUIViewRep.swift
//  Map Map
//
//  Created by Ben Roberts on 9/13/23.
//

import MapKit
import SwiftUI

extension MapMap: UIViewRepresentable {
    func makeUIView(context: Context) -> MKMapView {
        var mapView = MKMapView()
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) { }
}
