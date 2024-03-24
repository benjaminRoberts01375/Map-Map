//
//  MeasurementsVM.swift
//  Map Map
//
//  Created by Ben Roberts on 3/24/24.
//

import MapKit
import SwiftUI

extension MeasurementsV {
    @Observable
    final class ViewModel {
        var measurementPoints: [MapMeasurementCoordinate : CGPoint] = [:]
    }
    
    func generateOnScreenPoints() {
        var measurementPoints: [MapMeasurementCoordinate : CGPoint] = [:]
        let spanMultiplier = 2.0
        let correctedSpan = MKCoordinateSpan(
            latitudeDelta: mapDetails.region.span.latitudeDelta * spanMultiplier,
            longitudeDelta: mapDetails.region.span.longitudeDelta * spanMultiplier
        )
        let ssMapMesh = CGRect(
            x: mapDetails.region.center.latitude - correctedSpan.latitudeDelta / 2,
            y: mapDetails.region.center.longitude - correctedSpan.longitudeDelta / 2,
            width: correctedSpan.latitudeDelta,
            height: correctedSpan.longitudeDelta
        )
        for coord in measurementCoords {
            guard let position = mapDetails.mapProxy?.convert(coord.coordinates, to: .global) else { continue }
            if ssMapMesh.contains(position) { measurementPoints[coord] = position }
        }
        viewModel.measurementPoints = measurementPoints
    }
}
