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
    @Binding var screenSpaceUserLocation: CGPoint?
    @Binding var screenSpaceMarkerLocations: [Marker : CGPoint]
    let mapScope: Namespace.ID
    
    var body: some View {
        MapReader { mapContext in
            Map(
                position: $backgroundMapDetails.mapCamera,
                interactionModes: backgroundMapDetails.allowsInteraction ? [.pan, .rotate, .zoom] : [],
                scope: mapScope
            ) {
                ForEach(mapMaps) { mapMap in
                    if let name = mapMap.mapMapName, mapMap.isSetup && !mapMap.isEditing {
                        Annotation(
                            "\(name)",
                            coordinate: mapMap.coordinates,
                            anchor: .center
                        ) {
                            Button(action: {
                                withAnimation {
                                    backgroundMapDetails.mapCamera = .camera(MapCamera(centerCoordinate: mapMap.coordinates, distance: mapMap.mapDistance, heading: -mapMap.mapMapRotation))
                                }
                            }, label: {
                                AnyView(mapMap.getMap(.fullImage))
                                    .frame(width: backgroundMapDetails.scale * mapMap.mapMapScale)
                                    .rotationEffect(backgroundMapDetails.rotation - Angle(degrees: mapMap.mapMapRotation))
                                    .offset(y: -7)
                            })
                            .contextMenu { MapMapContextMenuV(mapMap: mapMap) }
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
                    self.screenSpaceUserLocation = screenSpaceUserLocation
                }
                var screenSpaceMarkerPositions: [Marker : CGPoint] = [:]
                for marker in markers {
                    guard let screenSpaceMarkerPosition = mapContext.convert(marker.coordinates, to: .local)
                    else { return }
                    screenSpaceMarkerPositions[marker] = screenSpaceMarkerPosition
                }
                self.screenSpaceMarkerLocations = screenSpaceMarkerPositions
            }
            .mapStyle(.standard(elevation: .realistic))
            .onAppear { locationsHandler.startLocationTracking() }
            .onDisappear { locationsHandler.stopLocationTracking() }
            .onChange(of: $locationsHandler.lastLocation.wrappedValue) { _, newLocation in
                if let screenSpaceUserLocation = mapContext.convert(newLocation.coordinate, to: .local) {
                    self.screenSpaceUserLocation = screenSpaceUserLocation
                }
            }
            .animation(.linear, value: screenSpaceUserLocation)
        }
    }
}
