//
//  MapUI.swift
//  Map Map
//
//  Created by Ben Roberts on 9/13/23.
//

import MapKit
import SwiftUI

struct BackgroundMap: View {
    @FetchRequest(sortDescriptors: []) var mapMaps: FetchedResults<MapMap>
    @EnvironmentObject var backgroundMapDetails: BackgroundMapDetailsM
    
    var body: some View {
        GeometryReader { geo in
            Map(
                position: $backgroundMapDetails.mapCamera,
                interactionModes: backgroundMapDetails.allowsInteraction ? [.pan, .rotate, .zoom] : []
            ) {
                UserAnnotation()
                ForEach(mapMaps) { map in
                    if let coordinates = map.coordinates,
                       let rotation = map.mapMapRotation as? Double,
                       let name = map.mapMapName,
                       let scale = map.mapMapScale as? Double {
                        Annotation(
                            "\(name)",
                            coordinate: coordinates,
                            anchor: .center
                        ) {
                            AnyView(map.getMap(.fullImage))
                                .frame(width: backgroundMapDetails.scale * scale)
                                .rotationEffect(backgroundMapDetails.rotation - Angle(degrees: rotation))
                                .offset(y: -7)
                        }
                    }
                }
            }
            .onMapCameraChange(frequency: .continuous) { update in
                backgroundMapDetails.scale = 1 / update.camera.distance
                backgroundMapDetails.rotation = Angle(degrees: -update.camera.heading)
                backgroundMapDetails.position = update.region.center
            }
            .safeAreaPadding([.top, .leading, .trailing])
            .mapStyle(.standard(elevation: .realistic))
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView(anchorEdge: .trailing)
            }
        }
    }
}

#Preview {
    BackgroundMap()
}
