//
//  MeasurementsV.swift
//  Map Map
//
//  Created by Ben Roberts on 3/24/24.
//

import SwiftUI

struct MeasurementsV: View {
    @Environment(MapDetailsM.self) var mapDetails
    @FetchRequest(sortDescriptors: []) var measurementCoordinates: FetchedResults<MapMeasurementCoordinate>
    @State var viewModel: ViewModel = ViewModel()
    
    var body: some View {
        ZStack {
            ForEach(Array(viewModel.connections.enumerated()), id: \.offset) { _, connection in
                ZStack { MeasurementV(connection: connection) }
            }
        }
        .onChange(of: measurementCoordinates.count, initial: true) {
            print("Count changed")
            Task {
                let connections = determineConnections()
                await MainActor.run {
                    self.viewModel.connections = connections
                }
            }
        }
    }
}
