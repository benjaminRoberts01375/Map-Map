//
//  BackgroundMapPointsV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/20/23.
//

import MapKit
import SwiftUI

struct BackgroundMapPointsV: View {
    @Environment(BackgroundMapDetailsM.self) private var backgroundMapDetails
    @FetchRequest(sortDescriptors: []) private var markers: FetchedResults<Marker>
    @FetchRequest(sortDescriptors: []) private var mapMaps: FetchedResults<MapMap>
    @Environment(\.managedObjectContext) private var moc
    @Environment(ScreenSpacePositionsM.self) private var screenSpacePositions
    let screenSize: CGSize
    static let iconSize: CGFloat = 30
    private let userLocationSize: CGFloat = 24
    
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
        let yComponent = abs(markerPos.y - screenSize.height / 2)
        let distance = sqrt(pow(xComponent, 2) + pow(yComponent, 2))
        return distance < BackgroundMapPointsV.iconSize / 2
    }
}
