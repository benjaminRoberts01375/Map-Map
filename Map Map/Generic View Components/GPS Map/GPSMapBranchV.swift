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
    @State var lineEnds: [Connection] = []
    
    var body: some View {
        ForEach(lineEnds) { connection in
            Line(startingPos: CGSize(cgPoint: connection.start), endingPos: CGSize(cgPoint: connection.end))
                .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .foregroundStyle(connection.color)
        }
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
    
    func calculateSSLineEndPos() async -> [Connection] {
        var result: [Connection] = []
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
        for connection in gpsMapBranch.unwrappedConnections {
            if let startCoord = connection.start,
               let endCoord = connection.end,
               ssMapMesh.contains(CGPoint(x: startCoord.coordinates.latitude, y: startCoord.coordinates.longitude)) ||
                ssMapMesh.contains(CGPoint(x: endCoord.coordinates.latitude, y: endCoord.coordinates.longitude)),
               let startPoint = mapDetails.mapProxy?.convert(startCoord.coordinates, to: .global),
               let endPoint = mapDetails.mapProxy?.convert(endCoord.coordinates, to: .global) {
                result.append(
                    Connection(
                        start: result.last?.end ?? startPoint,
                        end: endPoint,
                        color: connection.branch?.branchColor ?? GPSMapConnectionColor.defaultColor
                    )
                )
            }
        }
        return result
    }
}
