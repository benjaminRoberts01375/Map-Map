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
        var clusters: [[Connection]] = []
        var ssClusters: [[SSConnection]] = []
    }
    
    struct Connection {
        let startNode: MapMeasurementCoordinate
        let endNode: MapMeasurementCoordinate
        let distance: Measurement<UnitLength>
    }
    
    struct SSConnection: Identifiable {
        let startPoint: CGPoint
        let endPoint: CGPoint
        let distance: Measurement<UnitLength>
        let id = UUID()
    }
    
    func determineEdges() -> [[Connection]] { // BFS
        var connections: [[Connection]] = []
        var visited: Set<MapMeasurementCoordinate> = []

        for node in measurementCoordinates {
            if visited.contains(node) {
                continue
            }

            var clusterConnections: [Connection] = []
            var queue: [MapMeasurementCoordinate] = [node]
            visited.insert(node)

            while !queue.isEmpty {
                let currentNode = queue.removeFirst()

                for neighborNode in currentNode.formattedNeighbors {
                    let start = CLLocation(latitude: currentNode.latitude, longitude: currentNode.longitude)
                    let end = CLLocation(latitude: neighborNode.latitude, longitude: neighborNode.longitude)
                    if !visited.contains(neighborNode) {
                        let connection = Connection(
                            startNode: currentNode,
                            endNode: neighborNode,
                            distance: Measurement(value: start.distance(from: end), unit: .meters)
                        )
                        clusterConnections.append(connection)
                        visited.insert(neighborNode)
                        queue.append(neighborNode)
                    }
                }
            }

            if !clusterConnections.isEmpty {
                connections.append(clusterConnections)
            }
        }

        return connections
    }
    
    func determineSSConnectionPoints() -> [[SSConnection]] {
        var clusters: [[SSConnection]] = []
        for cluster in viewModel.clusters {
            var edges: [SSConnection] = []
            for edge in cluster {
                guard let startPos = mapDetails.mapProxy?.convert(edge.startNode.coordinates, to: .global),
                      let endPos = mapDetails.mapProxy?.convert(edge.endNode.coordinates, to: .global)
                else { continue }
                edges.append(
                    SSConnection(startPoint: startPos, endPoint: endPos, distance: edge.distance)
                )
            }
            clusters.append(edges)
        }
        return clusters
    }
}
