//
//  GpsMapBranchV.swift
//  Map Map
//
//  Created by Ben Roberts on 3/5/24.
//

import MapKit
import SwiftUI

struct GPSMapBranchV: View {
    /// Info about the base map.
    @Environment(MapDetailsM.self) var mapDetails
    @ObservedObject var gpsMapBranch: GPSMapBranch
    @State var lineEnds: [CGPoint] = []
    
    var body: some View {
        MultiLine(points: lineEnds)
            .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round))
            .foregroundStyle(gpsMapBranch.branchColor)
            .onChange(of: mapDetails.mapCamera) { setSSLineEndPos() }
            .onChange(of: gpsMapBranch.connections?.count) { setSSLineEndPos() }
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
    
    func calculateSSLineEndPos() async -> [CGPoint] {
        let spanMultiplier = 1.1
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
        var final: [CGPoint] = []
        for connection in gpsMapBranch.unwrappedConnections {
            if let endCoord = connection.end,
               ssMapMesh.contains(CGPoint(x: endCoord.coordinates.latitude, y: endCoord.coordinates.longitude)),
               let endPoint = mapDetails.mapProxy?.convert(endCoord.coordinates, to: .global) {
                final.append(endPoint)
            }
        }
        return final
    }
}
