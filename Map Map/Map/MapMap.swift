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
    @State var cameraPos: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    @State var scale: Double = 1
    @State var rotation: Angle = .zero
    
    var body: some View {
        GeometryReader { geo in
            Map(position: $cameraPos) {
                UserAnnotation()
                ForEach(maps) { map in
                    Annotation(
                        "\(map.mapName ?? "")",
                        coordinate: CLLocationCoordinate2D(latitude: 44.47301, longitude: -73.20390),
                        anchor: .center
                    )
                    {
                        AnyView(map.getMap(.fullImage))
                            .frame(width: 50 * scale, height: 50 * scale)
                            .rotationEffect(rotation)
                    }
                }
            }
            .onMapCameraChange(frequency: .continuous) { update in
                scale = 10000 / update.camera.distance
                rotation = Angle(degrees: -update.camera.heading)
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
