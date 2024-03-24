//
//  MeasurementV.swift
//  Map Map
//
//  Created by Ben Roberts on 3/24/24.
//

import MapKit
import SwiftUI

struct MeasurementV: View {
    @Environment(MapDetailsM.self) var mapDetails
    @ObservedObject var start: MapMeasurementCoordinate
    @ObservedObject var end: MapMeasurementCoordinate
    @State var startPoint: CGPoint = .zero
    @State var endPoint: CGPoint = .zero
    let distance: Measurement<UnitLength>
    
    init(connection: MeasurementsV.Connection) {
        self.start = connection.startNode
        self.end = connection.endNode
        self.distance = connection.distance
    }
    
    var body: some View {
        ZStack {
            if abs(startPoint.distanceTo(endPoint)) > 50 {
                // Outline line
                Line(startingPos: CGSize(cgPoint: startPoint), endingPos: CGSize(cgPoint: endPoint))
                    .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .foregroundStyle(.black.opacity(0.5))
                // Foreground line
                Line(startingPos: CGSize(cgPoint: startPoint), endingPos: CGSize(cgPoint: endPoint))
                    .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .lineLabel(
                        startingPos: startPoint,
                        endingPos: endPoint,
                        distance: distance
                    )
            }
        }
        .onChange(of: start.coordinates) { Task { await determineSSPos() } }
        .onChange(of: end.coordinates) { Task { await determineSSPos() } }
        .onChange(of: mapDetails.mapCamera) { Task { await determineSSPos() } }
        .task { await determineSSPos() }
    }
    
    /// Determine where the start and end points should be on the map
    func determineSSPos() async {
        let startPos = mapDetails.mapProxy?.convert(start.coordinates, to: .global)
        let endPos = mapDetails.mapProxy?.convert(end.coordinates, to: .global)
        await MainActor.run {
            self.startPoint = startPos ?? .zero
            self.endPoint = endPos ?? .zero
        }
    }
}
