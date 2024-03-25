//
//  MapMeasurementCoordinates.swift
//  Map Map
//
//  Created by Ben Roberts on 3/24/24.
//

import MapKit
import SwiftUI

struct MapMeasurementCoordinateV: View {
    /// Map details of the background map.
    @Environment(MapDetailsM.self) var mapDetails
    /// Starting coordinate to render.
    @ObservedObject var start: MapMeasurementCoordinate
    /// Ending coordinate to render.
    @ObservedObject var end: MapMeasurementCoordinate
    /// Starting coordinate as a CGPoint.
    @State var startPoint: CGPoint = .zero
    /// Ending coordinate as a CGPoint,
    @State var endPoint: CGPoint = .zero
    /// Distance between points.
    let distance: Measurement<UnitLength>
    
    init(connection: MapMeasurementCoordinatesV.Connection) {
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
                    .foregroundStyle(.white.opacity(0.5))
                // Foreground line
                Line(startingPos: CGSize(cgPoint: startPoint), endingPos: CGSize(cgPoint: endPoint))
                    .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .foregroundStyle(.black.opacity(0.5))
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
