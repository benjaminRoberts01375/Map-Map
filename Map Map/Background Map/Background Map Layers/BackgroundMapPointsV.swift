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
    let screenSize: CGSize
    static let iconSize: CGFloat = 30
    let userLocationSize: CGFloat = 24
    
    var body: some View {
        ForEach(markers) { marker in
            if let position = screenSpaceMarkerLocations[marker], !marker.isEditing {
                ZStack {
                    Button {
                        let distance: Double = 6000
                        withAnimation {
                            backgroundMapDetails.mapCamera = .camera(MapCamera(centerCoordinate: marker.coordinates, distance: distance, heading: -(marker.lockRotationAngleDouble ?? 0)))
                        }
                    } label: {
                        MarkerV(marker: marker)
                            .rotationEffect(backgroundMapDetails.rotation - Angle(degrees: marker.lockRotationAngleDouble ?? 0))
                    }
                    .contextMenu { MarkerContextMenuV(screenSpaceMarkerLocations: $screenSpaceMarkerLocations, marker: marker) }
                    .frame(width: BackgroundMapPointsV.iconSize, height: BackgroundMapPointsV.iconSize)
                    if let markerName = marker.name, isOverMarker(marker) {
                        Text(markerName)
                            .shadow(color: .black.opacity(2), radius: 3)
                            .padding(5)
                            .background {
                                Color.black
                                    .opacity(0.35)
                                    .blur(radius: 5)
                            }
                            .allowsHitTesting(false)
                            .offset(y: BackgroundMapPointsV.iconSize)
                    }
                }
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
    
    func isOverMarker(_ marker: Marker) -> Bool {
        guard let markerPos = screenSpaceMarkerLocations[marker] else { return false }
        let xComponent = abs(markerPos.x - screenSize.width  / 2)
        let yComponent = abs(markerPos.y - screenSize.height / 2)
        let distance = sqrt(pow(xComponent, 2) + pow(yComponent, 2))
        return distance < BackgroundMapPointsV.iconSize / 2
    }
}
