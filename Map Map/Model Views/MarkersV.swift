//
//  MarkersV.swift
//  Map Map
//
//  Created by Ben Roberts on 4/4/24.
//

import SwiftUI

struct MarkersV: View {
    /// All available markers.
    @FetchRequest(sortDescriptors: []) private var markers: FetchedResults<Marker>
    /// Information about the map.
    @Environment(MapDetailsM.self) private var mapDetails
    /// Screen size to use for Marker intersection calculations.
    let screenSize: CGSize
    
    var body: some View {
        ForEach(markers) { marker in
            if let position = mapDetails.mapProxy?.convert(marker.coordinate, to: .global), !marker.isEditing && marker.shown {
                ZStack {
                    Button {
                        mapDetails.moveMapCameraTo(item: marker)
                    } label: {
                        MarkerV(marker: marker)
                            .rotationEffect(
                                Angle(degrees: -mapDetails.mapCamera.heading -
                                      (marker.lockRotationAngleDouble ?? -mapDetails.mapCamera.heading))
                            )
                    }
                    .contextMenu { MarkerContextMenuV(marker: marker) }
                    .frame(width: MarkerV.iconSize, height: MarkerV.iconSize)
                    if let markerName = marker.name, isOverMarker(marker) {
                        Text(markerName)
                            .mapLabel()
                            .foregroundStyle(.white)
                            .allowsHitTesting(false)
                            .offset(y: MarkerV.iconSize)
                    }
                }
                .position(position)
            }
        }
    }
    
    /// Check if the center of the map is over a Marker.
    func isOverMarker(_ marker: Marker) -> Bool {
        guard let markerPos = mapDetails.mapProxy?.convert(marker.coordinate, to: .global) else { return false }
        let xComponent = abs(markerPos.x - screenSize.width / 2)
        let yComponent = abs(markerPos.y - (screenSize.height / 2))
        let distance = sqrt(pow(xComponent, 2) + pow(yComponent, 2))
        return distance < MarkerV.iconSize / 2
    }
}
