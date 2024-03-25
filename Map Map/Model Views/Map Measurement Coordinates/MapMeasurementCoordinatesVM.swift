//
//  MeasurementsVM.swift
//  Map Map
//
//  Created by Ben Roberts on 3/24/24.
//

import MapKit
import SwiftUI

extension MapMeasurementCoordinatesV {
    struct Connection {
        let startNode: MapMeasurementCoordinate
        let endNode: MapMeasurementCoordinate
        let distance: Measurement<UnitLength>
    }
    
    /// Determine all connections that the MapMeasurementCoordinates create
    /// - Returns: All available connections
    func determineConnections() -> [Connection] { // BFS
        if self.mapMeasurementCoordinates.count == 1, let lostSoul = self.mapMeasurementCoordinates.first { moc.delete(lostSoul) }
        else if self.mapMeasurementCoordinates.count < 2 { return [] }
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
        
        for node in mapMeasurementCoordinates {
            if visited.contains(node) { continue }
            var queue: Set<MapMeasurementCoordinate> = [node]

            while !queue.isEmpty {
                let currentNode = queue.removeFirst()
                visited.insert(currentNode)

                for neighborNode in currentNode.unwrappedNeighbors {
                    let start = CLLocation(latitude: currentNode.latitude, longitude: currentNode.longitude)
                    let end = CLLocation(latitude: neighborNode.latitude, longitude: neighborNode.longitude)
                    let startPos = CGPoint(x: currentNode.latitude, y: currentNode.longitude)
                    let endPos = CGPoint(x: neighborNode.latitude, y: neighborNode.longitude)
                    if !visited.contains(neighborNode) && (ssMapMesh.contains(startPos) || ssMapMesh.contains(endPos)) {
                        let connection = Connection(
                            startNode: currentNode,
                            endNode: neighborNode,
                            distance: Measurement(value: start.distance(from: end), unit: .meters)
                        )
                        connections.append(connection)
                        queue.insert(neighborNode)
                    }
                }
            }
        }
        return connections
    }
}
