//
//  MapUI.swift
//  Map Map
//
//  Created by Ben Roberts on 9/13/23.
//

import MapKit
import SwiftUI

/// Background map to be plotted on top of.
struct BackgroundMap: View {
    /// All available MapMaps.
    @FetchRequest(sortDescriptors: []) private var mapMaps: FetchedResults<MapMap>
    /// All available Markers.
    @FetchRequest(sortDescriptors: []) private var markers: FetchedResults<Marker>
    /// Background map details to be updated by this map.
    @Environment(BackgroundMapDetailsM.self) private var backgroundMapDetails: BackgroundMapDetailsM
    /// GPS user location.
    @State private var locationsHandler = LocationsHandler.shared
    /// Screen-space positions of MapMaps, Markers, and the user location.
    @Environment(ScreenSpacePositionsM.self) private var screenSpacePositions
    /// Track if MapMaps are tappable.
    @State private var tappableMapMaps = true
    /// Background map ID.
    let mapScope: Namespace.ID
    
    var body: some View {
        @Bindable var backgroundMapDetails = backgroundMapDetails
        
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
                                    backgroundMapDetails.moveMapCameraTo(mapMap: mapMap)
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
                self.screenSpacePositions.setPositions(screenSpaceMarkerPositions)
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
                self.screenSpacePositions.setPositions(screenSpaceMapMapPositions)
            }
            .mapStyle(.standard(elevation: .realistic))
            .onAppear { locationsHandler.startLocationTracking() }
            .onDisappear { locationsHandler.stopLocationTracking() }
            .onChange(of: $locationsHandler.lastLocation.wrappedValue) { _, newLocation in
                if let screenSpaceUserLocation = mapContext.convert(newLocation.coordinate, to: .local) {
                    self.screenSpacePositions.userLocation = screenSpaceUserLocation
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .editedMarkerLocation)) { notification in
                if let marker = notification.userInfo?["marker"] as? Marker,
                    let screenSpaceMarkerLocation = mapContext.convert(marker.coordinates, to: .local) {
                    screenSpacePositions[marker] = screenSpaceMarkerLocation
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
