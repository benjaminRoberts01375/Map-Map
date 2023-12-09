//
//  BackgroundMapPointsV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/20/23.
//

import MapKit
import SwiftUI

/// Points that cannot be Annotations on the background map.
struct BackgroundMapPointsV: View {
    /// Information about the background map.
    @Environment(BackgroundMapDetailsM.self) private var backgroundMapDetails
    /// All available markers.
    @FetchRequest(sortDescriptors: []) private var markers: FetchedResults<Marker>
    /// Screen space positions of Markers, MapMaps, and user location.
    @Environment(ScreenSpacePositionsM.self) private var screenSpacePositions
    /// Size of the parent view.
    let screenSize: CGSize
    /// Marker icon size.
    static let iconSize: CGFloat = 30
    /// User location icon size.
    private let userLocationSize: CGFloat = 24
    
    private let markerOffset: CGFloat = -2
    
    var body: some View {
        ForEach(markers) { marker in
            if let position = screenSpacePositions.markerPositions[marker], !marker.isEditing && marker.shown {
                ZStack {
                    Button {
                        backgroundMapDetails.moveMapCameraTo(marker: marker)
                    } label: {
                        MarkerV(marker: marker)
                            .rotationEffect(
                                backgroundMapDetails.rotation -
                                Angle(degrees: marker.lockRotationAngleDouble ?? backgroundMapDetails.rotation.degrees)
                            )
                            .offset(y: markerOffset)
                    }
                    .contextMenu {
                        MarkerContextMenuV(marker: marker) {
                            screenSpacePositions.markerPositions.removeValue(forKey: marker)
                        }
                    }
                    .frame(width: BackgroundMapPointsV.iconSize, height: BackgroundMapPointsV.iconSize)
                    if let markerName = marker.name, isOverMarker(marker) {
                        Text(markerName)
                            .shadow(color: .black.opacity(0.5), radius: 3)
                            .padding(5)
                            .background {
                                Color.black
                                    .opacity(0.35)
                                    .blur(radius: 10)
                            }
                            .foregroundStyle(.white)
                            .allowsHitTesting(false)
                            .offset(y: BackgroundMapPointsV.iconSize)
                    }
                }
                .position(position)
            }
        }
        VStack {
            if let screenSpaceUserLocation = screenSpacePositions.userLocation {
                MapUserIcon()
                    .frame(width: userLocationSize, height: userLocationSize)
                    .position(screenSpaceUserLocation)
            }
            else { EmptyView() }
        }
        .ignoresSafeArea()
    }
    
    func isOverMarker(_ marker: Marker) -> Bool {
        guard let markerPos = screenSpacePositions.markerPositions[marker] else { return false }
        let xComponent = abs(markerPos.x - screenSize.width / 2)
        let yComponent = abs(markerPos.y - (screenSize.height / 2 - markerOffset))
        let distance = sqrt(pow(xComponent, 2) + pow(yComponent, 2))
        return distance < BackgroundMapPointsV.iconSize / 2
    }
}
