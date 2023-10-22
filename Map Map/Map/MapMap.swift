//
//  MapUI.swift
//  Map Map
//
//  Created by Ben Roberts on 9/13/23.
//

import MapKit
import SwiftUI

struct MapMap: View {
    @FetchRequest(sortDescriptors: []) var maps: FetchedResults<MapPhoto>
    @EnvironmentObject var mapDetails: MapDetailsM
    
    var body: some View {
        GeometryReader { geo in
            Map(
                initialPosition: .userLocation(fallback: .automatic),
                interactionModes: mapDetails.allowsInteraction ? [.pan, .rotate, .zoom] : []
            ) {
                UserAnnotation()
                ForEach(maps) { map in
                    if let coordinates = map.coordinates,
                       let rotation = map.rotation as? Double,
                       let name = map.mapName,
                       let scale = map.scale as? Double {
                        Annotation(
                            "\(name)",
                            coordinate: coordinates,
                            anchor: .center
                        ) {
                            AnyView(map.getMap(.fullImage))
                                .frame(width: mapDetails.scale * scale)
                                .rotationEffect(mapDetails.rotation - Angle(degrees: rotation))
                                .offset(y: -7)
                        }
                    }
                }
            }
            .onMapCameraChange(frequency: .continuous) { update in
                mapDetails.scale = 1 / update.camera.distance
                mapDetails.rotation = Angle(degrees: -update.camera.heading)
                mapDetails.position = update.region.center
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
    MapMap()
}
