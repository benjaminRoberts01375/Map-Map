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
        var connections: [Connection] = []
    }
    
    struct Connection {
        let startNode: MapMeasurementCoordinate
        let endNode: MapMeasurementCoordinate
        let distance: Measurement<UnitLength>
    }
    
    func determineConnections() -> [Connection] { // BFS
        var connections: [Connection] = []
        var visited: Set<MapMeasurementCoordinate> = []
        
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
        
        for node in measurementCoordinates {
            if visited.contains(node) { continue }
            var queue: [MapMeasurementCoordinate] = [node]
            visited.insert(node)

            while !queue.isEmpty {
                let currentNode = queue.removeFirst()

                for neighborNode in currentNode.unwrappedNeighbors {
                    let start = CLLocation(latitude: currentNode.latitude, longitude: currentNode.longitude)
                    let end = CLLocation(latitude: neighborNode.latitude, longitude: neighborNode.longitude)
                    let startPos = CGPoint(x: currentNode.latitude, y: currentNode.longitude)
                    let endPos = CGPoint(x: neighborNode.latitude, y: neighborNode.longitude)
                    if ssMapMesh.contains(startPos) || ssMapMesh.contains(endPos) {
                        let connection = Connection(
                            startNode: currentNode,
                            endNode: neighborNode,
                            distance: Measurement(value: start.distance(from: end), unit: .meters)
                        )
                        connections.append(connection)
                        visited.insert(neighborNode)
                    }
                    if !visited.contains(neighborNode) {
                        queue.append(neighborNode)
                    }
                }
            }
        }
        return connections
    }
}
