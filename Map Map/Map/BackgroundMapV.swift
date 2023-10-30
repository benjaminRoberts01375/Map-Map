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
    @Environment(\.managedObjectContext) var moc
    @State var locationsHandler = LocationsHandler.shared
    @State var screenSpaceUserLocation: CGPoint = .zero
    
    var body: some View {
        MapReader { mapContext in
            Map(
                position: $backgroundMapDetails.mapCamera,
                interactionModes: backgroundMapDetails.allowsInteraction ? [.pan, .rotate, .zoom] : []
            ) {
                ForEach(mapMaps) { map in
                    if let name = map.mapMapName {
                        Annotation(
                            "\(name)",
                            coordinate: map.coordinates,
                            anchor: .center
                        ) {
                            Button(action: {
                                withAnimation {
                                    backgroundMapDetails.mapCamera = .camera(MapCamera(centerCoordinate: map.coordinates, distance: map.mapDistance, heading: -map.mapMapRotation))
                                }
                            }, label: {
                                AnyView(map.getMap(.fullImage))
                                    .frame(width: backgroundMapDetails.scale * map.mapMapScale)
                                    .rotationEffect(backgroundMapDetails.rotation - Angle(degrees: map.mapMapRotation))
                                    .offset(y: -7)
                                    .opacity(map.isEditing ? 0.5 : 1)
                            })
                            .contextMenu { MapMapContextMenuV(mapMap: map) }
                        }
                    }
                }
            }
            .onMapCameraChange(frequency: .continuous) { update in
                backgroundMapDetails.scale = 1 / update.camera.distance
                backgroundMapDetails.rotation = Angle(degrees: -update.camera.heading)
                backgroundMapDetails.position = update.region.center
                if let screenSpaceUserLocation = mapContext.convert(locationsHandler.lastLocation.coordinate, to: .local) {
                    self.screenSpaceUserLocation = screenSpaceUserLocation
                }
            }
            .safeAreaPadding([.top, .leading, .trailing])
            .mapStyle(.standard(elevation: .realistic))
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView(anchorEdge: .trailing)
            }
            .overlay {
                MapUserIcon()
                    .position(screenSpaceUserLocation)
            }
            .onAppear { locationsHandler.startLocationTracking() }
            .onDisappear { locationsHandler.stopLocationTracking() }
            .onChange(of: $locationsHandler.lastLocation.wrappedValue) { _, newLocation in
                if let screenSpaceUserLocation = mapContext.convert(newLocation.coordinate, to: .local) {
                    self.screenSpaceUserLocation = screenSpaceUserLocation
                }
            }
        }
    }
}

#Preview {
    BackgroundMap()
}
