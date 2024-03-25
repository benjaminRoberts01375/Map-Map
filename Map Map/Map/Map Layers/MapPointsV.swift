//
//  mapPointsV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/20/23.
//

import ActivityKit
import MapKit
import SwiftUI

/// Points that cannot be Annotations on the map.
struct MapPointsV: View {
    /// Information about the map.
    @Environment(MapDetailsM.self) private var mapDetails
    /// All available markers.
    @FetchRequest(sortDescriptors: []) private var markers: FetchedResults<Marker>
    /// All available GPSMaps.
    @FetchRequest(sortDescriptors: []) private var gpsMaps: FetchedResults<GPSMap>
    /// GPS user location.
    @State private var locationsHandler = LocationsHandler.shared
    /// The user's location in screen-space
    @State private var ssUserLocation: CGPoint?
    /// Size of the parent view.
    let screenSize: CGSize
    /// Marker icon size.
    static let iconSize: CGFloat = 30
    /// Offset marker slightly for correct alignment.
    private let markerOffset: CGFloat = -2
    /// Min line length
    static let minLineLength: CGFloat = 70
    /// Track if the app is currently in the foreground.
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        GeometryReader { _ in
            ForEach(gpsMaps) { gpsMap in
                if gpsMap.shown { GPSMapV(gpsMap: gpsMap) }
            }
            
            MapMeasurementCoordinatesV()
                .allowsHitTesting(false)
            
            ForEach(markers) { marker in
                if let position = mapDetails.mapProxy?.convert(marker.coordinate, to: .global), !marker.isEditing && marker.shown {
                    ZStack {
                        Button {
                            mapDetails.moveMapCameraTo(item: marker)
                        } label: {
                            MarkerV(marker: marker)
                                .rotationEffect(
                                    Angle(degrees: -mapDetails.mapCamera.heading -
                                          (marker.lockRotationAngleDouble ?? -mapDetails.mapCamera.heading))
                                )
                                .offset(y: markerOffset)
                        }
                        .contextMenu { MarkerContextMenuV(marker: marker) }
                        .frame(width: MapPointsV.iconSize, height: MapPointsV.iconSize)
                        if let markerName = marker.name, isOverMarker(marker) {
                            Text(markerName)
                                .mapLabel()
                                .foregroundStyle(.white)
                                .allowsHitTesting(false)
                                .offset(y: MapPointsV.iconSize)
                        }
                    }
                    .position(position)
                }
            }
            VStack {
                let userLocation = CLLocationCoordinate2D(
                    latitude: locationsHandler.lastLocation.coordinate.latitude,
                    longitude: locationsHandler.lastLocation.coordinate.longitude
                )
                if let screenSpaceUserLocation = mapDetails.mapProxy?.convert(userLocation, to: .global) {
                    PingingUserIconV()
                        .position(screenSpaceUserLocation)
                }
                else { EmptyView() }
            }
            .ignoresSafeArea()
            .onAppear { locationsHandler.startLocationTracking() }
            .onDisappear { locationsHandler.stopLocationTracking() }
            .onChange(of: locationsHandler.lastLocation) { _, update in
                let userCoords = CLLocationCoordinate2D(
                    latitude: update.coordinate.latitude,
                    longitude: update.coordinate.longitude
                )
                if let ssUserLocation = mapDetails.mapProxy?.convert(userCoords, to: .global) {
                    self.ssUserLocation = ssUserLocation
                }
            }
            .animation(.linear, value: ssUserLocation)
        }
        .onChange(of: scenePhase) {
            switch scenePhase {
            case .active: locationsHandler.startLocationTracking()
            default: if Activity<GPSTrackingAttributes>.activities.isEmpty { locationsHandler.stopLocationTracking() }
            }
        }
    }
    
    /// Check if the center of the map is over a Marker.
    func isOverMarker(_ marker: Marker) -> Bool {
        guard let markerPos = mapDetails.mapProxy?.convert(marker.coordinate, to: .global) else { return false }
        let xComponent = abs(markerPos.x - screenSize.width / 2)
        let yComponent = abs(markerPos.y - (screenSize.height / 2 - markerOffset))
        let distance = sqrt(pow(xComponent, 2) + pow(yComponent, 2))
        return distance < MapPointsV.iconSize / 2
    }
    
}
