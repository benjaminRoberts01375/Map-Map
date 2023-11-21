//
//  BackgroundMapPointsV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/20/23.
//

import MapKit
import SwiftUI

struct BackgroundMapPointsV: View {
    @EnvironmentObject var backgroundMapDetails: BackgroundMapDetailsM
    @FetchRequest(sortDescriptors: []) var markers: FetchedResults<Marker>
    @Environment(\.managedObjectContext) var moc
    @Binding var screenSpaceUserLocation: CGPoint?
    @Binding var screenSpaceMarkerLocations: [CGPoint]?
    let iconSize: CGFloat = 30
    let userLocationSize: CGFloat = 24
    
    var body: some View {
        if let screenSpaceUserLocation = screenSpaceUserLocation {
            MapUserIcon()
                .frame(width: userLocationSize, height: userLocationSize)
                .position(screenSpaceUserLocation)
        }
        else { EmptyView() }
        
        if let screenSpaceMarkerLocations = screenSpaceMarkerLocations, markers.count == screenSpaceMarkerLocations.count {
            ForEach(Array(markers.enumerated()), id: \.offset) { i, marker in
                Button {
                    withAnimation {
                        backgroundMapDetails.mapCamera = .camera(MapCamera(centerCoordinate: marker.coordinates, distance: 6000, heading: 0))
                    }
                } label: {
                    marker.thumbnail
                }
                .contextMenu {
                    Button(role: .destructive) {
                        moc.delete(marker)
                        self.screenSpaceMarkerLocations?.remove(at: i)
                        try? moc.save()
                    } label: {
                        Label("Delete Marker", systemImage: "trash.fill")
                    }
                }
                .frame(width: iconSize, height: iconSize)
                .position(screenSpaceMarkerLocations[i])
//                .offset(x: 16, y: 15)
            }
        }
    }
}
