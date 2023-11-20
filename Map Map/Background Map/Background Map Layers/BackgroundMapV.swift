//
//  MapUI.swift
//  Map Map
//
//  Created by Ben Roberts on 9/13/23.
//

import MapKit
import SwiftUI

struct BackgroundMap: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var mapMaps: FetchedResults<MapMap>
    @FetchRequest(sortDescriptors: []) var markers: FetchedResults<Marker>
    @EnvironmentObject var backgroundMapDetails: BackgroundMapDetailsM
    @State var locationsHandler = LocationsHandler.shared
    @State var screenSpaceUserLocation: CGPoint?
    @State var screenSpaceMarkerLocations: [CGPoint]?
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
                var screenSpaceMarkerPositions: [CGPoint] = []
                for marker in markers {
                    guard let screenSpaceMarkerPosition = mapContext.convert(marker.coordinates, to: .local)
                    else { return }
                    screenSpaceMarkerPositions.append(screenSpaceMarkerPosition)
                }
                self.screenSpaceMarkerLocations = screenSpaceMarkerPositions
            }
            .overlay {
                if let screenSpaceUserLocation = screenSpaceUserLocation {
                    MapUserIcon()
                        .position(screenSpaceUserLocation)
                }
                else { EmptyView() }
                
                if let screenSpaceMarkerLocations = screenSpaceMarkerLocations, markers.count == screenSpaceMarkerLocations.count {
                    ForEach(Array(markers.enumerated()), id: \.offset) { i, marker in
                        Button {
                            withAnimation {
                                backgroundMapDetails.mapCamera = .camera(MapCamera(centerCoordinate: marker.coordinates, distance: 6000, heading: 0))
                            }
                        } label: {
                            marker.thumbnail
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                moc.delete(marker)
                                try? moc.save()
                            } label: {
                                Label("Delete Marker", systemImage: "trash.fill")
                            }
                        }
                        .frame(width: 30, height: 30)
                        .position(screenSpaceMarkerLocations[i])
                        .offset(y: -7)
                    }
                }
            }
            .safeAreaPadding([.top, .leading, .trailing])
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

#Preview {
    BackgroundMap(mapScope: Namespace().wrappedValue)
}
