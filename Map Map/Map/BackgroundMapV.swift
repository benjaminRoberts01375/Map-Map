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
                if let userLocation = CLLocationManager().location?.coordinate {
                    Annotation(
                        "",
                        coordinate: CLLocationCoordinate2D(latitude: userLocation.latitude, longitude: userLocation.longitude),
                        anchor: .center
                    ) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundStyle(.white, .blue)
                            .frame(width: 25, height: 25)
                            .offset(y: -1)
                    }
                }
                
                ForEach(mapMaps) { map in
                    if let name = map.mapMapName {
                        Annotation(
                            "\(name)",
                            coordinate: map.coordinates,
                            anchor: .center
                        ) {
                            AnyView(map.getMap(.fullImage))
                                .frame(width: backgroundMapDetails.scale * map.mapMapScale)
                                .rotationEffect(backgroundMapDetails.rotation - Angle(degrees: map.mapMapRotation))
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
