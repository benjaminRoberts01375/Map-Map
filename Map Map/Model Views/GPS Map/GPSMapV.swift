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
    /// Connections not assigned to any specific branch.
    @State var looseConnections: [[CGPoint]] = []
    
    var body: some View {
        ZStack {
            ForEach(gpsMap.unwrappedBranches) { branch in
                GPSMapBranchV(gpsMapBranch: branch)
                    .onReceive(branch.objectWillChange) { setSSLineNodes() }
            }
            ForEach(looseConnections, id: \.self) { branch in
                MultiLine(points: branch)
                    .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .foregroundStyle(GPSMapConnectionColor.defaultColor)
            }
        }
        .onChange(of: mapDetails.mapCamera) { setSSLineNodes() }
        .onReceive(gpsMap.objectWillChange) { setSSLineNodes() }
    }
    
    /// Update line positions from the line end positions func.
    func setSSLineNodes() {
        Task {
            let lineNodes = await calculateSSLineEndPos()
            DispatchQueue.main.async {
                self.looseConnections = lineNodes
            }
        }
    }
    
    /// Calculate the screen-space line ending positions by converting coordinates to SS.
    func calculateSSLineEndPos() async -> [[CGPoint]] {
        let correctedSpan = mapDetails.region.span * 1.1
        let ssMapMesh = CGRect(
            x: mapDetails.region.center.latitude - correctedSpan.latitudeDelta / 2,
            y: mapDetails.region.center.longitude - correctedSpan.longitudeDelta / 2,
            width: correctedSpan.latitudeDelta,
            height: correctedSpan.longitudeDelta
        )
        var final: [[CGPoint]] = []
        var current: [CGPoint] = []
        var lastCoord: GPSMapCoordinate?
        
        for connection in gpsMap.unsortedConnections {
            if let startCoord = connection.start,
               let endCoord = connection.end,
               ssMapMesh.contains(CGPoint(x: startCoord.coordinates.latitude, y: startCoord.coordinates.longitude)) ||
                ssMapMesh.contains(CGPoint(x: endCoord.coordinates.latitude, y: endCoord.coordinates.longitude)),
               let startPoint = mapDetails.mapProxy?.convert(startCoord.coordinates, to: .global),
               let endPoint = mapDetails.mapProxy?.convert(endCoord.coordinates, to: .global) {
                if startCoord != lastCoord {
                    final.append(current)
                    current = .init()
                    current.append(startPoint)
                }
                current.append(endPoint)
                lastCoord = endCoord
            }
        }
        final.append(current)
        return final
    }
}
