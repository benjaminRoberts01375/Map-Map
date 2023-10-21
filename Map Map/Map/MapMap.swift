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
                    if let coordinates = map.coordinates {
                        Annotation(
                            "\(map.mapName ?? "")",
                            coordinate: coordinates,
                            anchor: .center
                        ) {
                            AnyView(map.getMap(.fullImage))
                                .frame(width: mapDetails.scale, height: mapDetails.scale)
                                .rotationEffect(mapDetails.rotation - Angle(degrees: Double(truncating: map.rotation ?? 0)))
                        }
                    }
                }
            }
            .onMapCameraChange(frequency: .continuous) { update in
                mapDetails.scale = 500000 / update.camera.distance
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
