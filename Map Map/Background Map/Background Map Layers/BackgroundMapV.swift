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
    @FetchRequest(sortDescriptors: []) var markers: FetchedResults<Marker>
    @EnvironmentObject var backgroundMapDetails: BackgroundMapDetailsM
    @State var locationsHandler = LocationsHandler.shared
    @Environment(ScreenSpacePositionsM.self) var screenSpacePositions
    @State var tappableMapMaps = true
    let mapScope: Namespace.ID
    
    var body: some View {
        MapReader { mapContext in
            Map(
                position: $backgroundMapDetails.mapCamera,
                interactionModes: backgroundMapDetails.allowsInteraction ? [.pan, .rotate, .zoom] : [],
                scope: mapScope
            ) {
                ForEach(mapMaps) { mapMap in
                    if let name = mapMap.mapMapName, mapMap.isSetup && !mapMap.isEditing && mapMap.shown {
                        Annotation(
                            "\(name)",
                            coordinate: mapMap.coordinates,
                            anchor: .center
                        ) {
                            if tappableMapMaps {
                                Button(action: {
                                    withAnimation {
                                        backgroundMapDetails.mapCamera = .camera(MapCamera(centerCoordinate: mapMap.coordinates, distance: mapMap.mapDistance, heading: -mapMap.mapMapRotation))
                                    }
                                }, label: {
                                    MapMapV(mapMap: mapMap, mapType: .fullImage)
                                        .frame(width: backgroundMapDetails.scale * mapMap.mapMapScale)
                                        .rotationEffect(backgroundMapDetails.rotation - Angle(degrees: mapMap.mapMapRotation))
                                        .offset(y: -7)
                                })
                                .contextMenu { MapMapContextMenuV(mapMap: mapMap) }
                            }
                            else {
                                MapMapV(mapMap: mapMap, mapType: .fullImage)
                                    .frame(width: backgroundMapDetails.scale * mapMap.mapMapScale)
                                    .rotationEffect(backgroundMapDetails.rotation - Angle(degrees: mapMap.mapMapRotation))
                                    .offset(y: -7)
                            }
                        }
                    }
                }
            }
            .mapControlVisibility(.hidden)
            .onMapCameraChange(frequency: .continuous) { update in
                backgroundMapDetails.scale = 1 / update.camera.distance
                backgroundMapDetails.rotation = Angle(degrees: -update.camera.heading)
                backgroundMapDetails.position = update.region.center
                backgroundMapDetails.span = update.region.span
                if let screenSpaceUserLocation = mapContext.convert(locationsHandler.lastLocation.coordinate, to: .local) {
                    self.screenSpacePositions.userLocation = screenSpaceUserLocation
                }
                var screenSpaceMarkerPositions: [Marker : CGPoint] = [:]
                for marker in markers {
                    guard let screenSpaceMarkerPosition = mapContext.convert(marker.coordinates, to: .local)
                    else { return }
                    screenSpaceMarkerPositions[marker] = screenSpaceMarkerPosition
                }
                self.screenSpacePositions.markerPositions = screenSpaceMarkerPositions
                var screenSpaceMapMapPositions: [MapMap : CGRect] = [:]
                for mapMap in mapMaps {
                    guard let center = mapContext.convert(mapMap.coordinates, to: .local)
                    else { return }
                    let size = backgroundMapDetails.scale * mapMap.mapMapScale
                    let rect = CGRect(
                        origin: center,
                        size: CGSize(
                            width: size,
                            height: size / mapMap.imageWidth * mapMap.imageHeight
                        )
                    )
                    screenSpaceMapMapPositions[mapMap] = rect
                }
                self.screenSpacePositions.mapMapPositions = screenSpaceMapMapPositions
            }
            .mapStyle(.standard(elevation: .realistic))
            .onAppear { locationsHandler.startLocationTracking() }
            .onDisappear { locationsHandler.stopLocationTracking() }
            .onChange(of: $locationsHandler.lastLocation.wrappedValue) { _, newLocation in
                if let screenSpaceUserLocation = mapContext.convert(newLocation.coordinate, to: .local) {
                    self.screenSpacePositions.userLocation = screenSpaceUserLocation
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .addedMarker)) { notification in
                if let marker = notification.userInfo?["marker"] as? Marker, let screenSpaceMarkerLocation = mapContext.convert(marker.coordinates, to: .local) {
                    screenSpacePositions.markerPositions[marker] = screenSpaceMarkerLocation
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .editingMarker)) { notification in
                if let editingStatus = notification.userInfo?["editing"] as? Bool {
                    tappableMapMaps = !editingStatus
                }
            }
            .animation(.linear, value: screenSpacePositions.userLocation)
        }
    }
}
