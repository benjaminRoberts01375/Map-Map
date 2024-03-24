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
            ForEach(Array(viewModel.ssClusters.enumerated()), id: \.offset) { _, cluster in
                ZStack {
                    ForEach(cluster) { edge in
                        ZStack {
                            Line(startingPos: CGSize(cgPoint: edge.startPoint), endingPos: CGSize(cgPoint: edge.endPoint)) // Outline line
                                .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                .foregroundStyle(.black.opacity(0.5))
                            Line(startingPos: CGSize(cgPoint: edge.startPoint), endingPos: CGSize(cgPoint: edge.endPoint)) // Foreground line
                                .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                                .lineLabel(
                                    startingPos: edge.startPoint,
                                    endingPos: edge.endPoint,
                                    distance: edge.distance
                                )
                        }
                    }
                }
            }
        }
        .onChange(of: measurementCoordinates.count, initial: true) {
            Task {
                let edges = determineEdges()
                let ssEdges = determineSSConnectionPoints()
                await MainActor.run {
                    self.viewModel.clusters = edges
                    self.viewModel.ssClusters = ssEdges
                }
            }
        }
        .onChange(of: mapDetails.mapCamera) {
            Task {
                let ssEdges = determineSSConnectionPoints()
                await MainActor.run { self.viewModel.ssClusters = ssEdges }
            }
        }
    }
}
