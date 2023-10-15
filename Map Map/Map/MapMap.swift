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
            Map(initialPosition: .userLocation(fallback: .automatic)) {
                UserAnnotation()
                ForEach(maps) { map in
                    if let coordinates = map.coordinates {
                        Annotation(
                            "\(map.mapName ?? "")",
                            coordinate: coordinates,
                            anchor: .center
                        ) {
                            AnyView(map.getMap(.fullImage))
                                .frame(width: 50 * mapDetails.scale, height: 50 * mapDetails.scale)
                                .rotationEffect(mapDetails.rotation)
                        }
                    }
                }
            }
            .onMapCameraChange(frequency: .continuous) { update in
                mapDetails.scale = 10000 / update.camera.distance
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
