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
    
    var body: some View {
        GeometryReader { geo in
            Map(position: $cameraPos) {
                ForEach(maps) { map in
                    if let coordinates = map.coordinates {
                        Annotation(
                            "Temp",
                            coordinate: coordinates,
                            anchor: .center,
                            content: { AnyView(map.getMap(.fullImage)) }
                        )
                    }
                }
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
