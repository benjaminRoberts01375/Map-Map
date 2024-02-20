//
//  GPSMapV.swift
//  Map Map
//
//  Created by Ben Roberts on 2/16/24.
//

import MapKit
import SwiftUI

struct GPSMapV: View {
    /// Info about the base map.
    @Environment(MapDetailsM.self) var mapDetails
    /// GPS Map to view.
    @ObservedObject var gpsMap: GPSMap
    /// Connection points for drawing lines
    @State var lineEnds: [Connection] = []
    
    var body: some View {
        ZStack {
            ForEach(lineEnds) { connection in
                Line(startingPos: CGSize(cgPoint: connection.start), endingPos: CGSize(cgPoint: connection.end)) // Outline line
                    .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .foregroundStyle(.blue)
            }
        }
        .onChange(of: mapDetails.mapCamera) { setSSLineEndPos() }
        .onChange(of: gpsMap.connections?.count) { setSSLineEndPos() }
    }
    
    /// Update line positions from the line end positions func.
    func setSSLineEndPos() {
        Task {
            let lines = await calculateSSLineEndPos()
            DispatchQueue.main.async {
                self.lineEnds = lines
            }
        }
    }
    
    /// Determine how to draw lines from coordinate points.
    /// - Returns: Calculated positions.
    func calculateSSLineEndPos() async -> [Connection] {
        var result: [Connection] = []
        for connection in gpsMap.unwrappedConnections {
            if let startCoord = connection.start,
               let endCoord = connection.end,
               let startPoint = mapDetails.mapProxy?.convert(startCoord.coordinates, to: .global),
               let endPoint = mapDetails.mapProxy?.convert(endCoord.coordinates, to: .global) {
                result.append(Connection(start: startPoint, end: endPoint))
            }
        }
        return result
    }
}
