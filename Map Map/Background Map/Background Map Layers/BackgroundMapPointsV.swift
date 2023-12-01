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
    @Binding var screenSpaceMarkerLocations: [Marker : CGPoint]
    static let iconSize: CGFloat = 30
    let userLocationSize: CGFloat = 24
    
    var body: some View {
        ForEach(markers) { marker in
            if let position = screenSpaceMarkerLocations[marker], !marker.isEditing {
                Button {
                    let distance: Double = 6000
                    if let rotation = marker.lockRotationAngleDouble {
                        withAnimation {
                            backgroundMapDetails.mapCamera = .camera(MapCamera(centerCoordinate: marker.coordinates, distance: distance, heading: -rotation))
                        }
                    }
                    else {
                        withAnimation {
                            backgroundMapDetails.mapCamera = .camera(MapCamera(centerCoordinate: marker.coordinates, distance: distance, heading: 0))
                        }
                    }
                } label: {
                    if let angle = marker.lockRotationAngleDouble {
                        MarkerV(marker: marker)
                            .rotationEffect(backgroundMapDetails.rotation - Angle(degrees: angle))
                    }
                    else {
                        MarkerV(marker: marker)
                    }
                }
                .contextMenu {
                    MarkerContextMenuV(screenSpaceMarkerLocations: $screenSpaceMarkerLocations, marker: marker)
                }
                .frame(width: BackgroundMapPointsV.iconSize, height: BackgroundMapPointsV.iconSize)
                .position(position)
            }
        }
        
        if let screenSpaceUserLocation = screenSpaceUserLocation {
            MapUserIcon()
                .frame(width: userLocationSize, height: userLocationSize)
                .position(screenSpaceUserLocation)
        }
        else { EmptyView() }
    }
}
