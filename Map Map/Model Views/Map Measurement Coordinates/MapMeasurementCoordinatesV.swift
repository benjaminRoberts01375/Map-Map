//
//  MapMeasurementCoordinatesV.swift
//  Map Map
//
//  Created by Ben Roberts on 3/24/24.
//

import SwiftUI

struct MapMeasurementCoordinatesV: View {
    /// Core Data managed object context
    @Environment(\.managedObjectContext) var moc
    /// Details of the background map
    @Environment(MapDetailsM.self) var mapDetails
    /// All available MapMeasurementCoordinates
    @FetchRequest(sortDescriptors: []) var mapMeasurementCoordinates: FetchedResults<MapMeasurementCoordinate>
    /// Connections formed by the map measurement coordinates
    @State var connections: [Connection] = []
    
    var body: some View {
        ZStack {
            ForEach(Array(connections.enumerated()), id: \.offset) { _, connection in
                ZStack { MapMeasurementCoordinateV(connection: connection) }
                    .onChange(of: connection.endNode.unwrappedNeighbors.count) {
                        Task {
                            let connections = determineConnections()
                            await MainActor.run {
                                self.connections = connections
                            }
                        }
                    }
                    .onChange(of: connection.startNode.unwrappedNeighbors.count) {
                        Task {
                            let connections = determineConnections()
                            await MainActor.run {
                                self.connections = connections
                            }
                        }
                    }
            }
        }
        .onChange(of: mapMeasurementCoordinates.count, initial: true) {
            Task {
                let connections = determineConnections()
                await MainActor.run {
                    self.connections = connections
                }
            }
        }
    }
}
