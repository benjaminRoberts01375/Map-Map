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
    /// All available GPSMaps.
    @FetchRequest(sortDescriptors: []) private var gpsMaps: FetchedResults<GPSMap>
    /// GPS user location.
    @State private var locationsHandler = LocationsHandler.shared
    /// The user's location in screen-space
    @State private var ssUserLocation: CGPoint?
    /// Size of the parent view.
    let screenSize: CGSize
    /// Track if the app is currently in the foreground.
    @Environment(\.scenePhase) private var scenePhase
    /// Current editor being used.
    @Binding var editor: Editor
    
    var body: some View {
        GeometryReader { _ in
            ForEach(gpsMaps) { gpsMap in
                if gpsMap.shown { GPSMapV(gpsMap: gpsMap) }
            }
            
            MapMeasurementCoordinatesV()
                .allowsHitTesting(false)
            
            MarkersV(screenSize: screenSize)
                .disabled(editor != .nothing)
            
            VStack {
                if let screenSpaceUserLocation = mapDetails.mapProxy?.convert(locationsHandler.lastLocation.coordinate, to: .global) {
                    PingingUserIconV()
                        .position(screenSpaceUserLocation)
                }
                else { EmptyView() }
            }
            .ignoresSafeArea()
        }
        .onAppear { locationsHandler.startLocationTracking() }
        .onDisappear { locationsHandler.stopLocationTracking() }
        .onChange(of: locationsHandler.lastLocation) { _, update in
            guard let ssUserLocation = mapDetails.mapProxy?.convert(update.coordinate, to: .global)
            else { return }
            self.ssUserLocation = ssUserLocation
        }
        .onChange(of: scenePhase) { // MARK: Control user location tracking.
            switch scenePhase {
            case .active: locationsHandler.startLocationTracking()
            default: if Activity<GPSTrackingAttributes>.activities.isEmpty { locationsHandler.stopLocationTracking() }
            }
        }
        .animation(.linear, value: ssUserLocation)
    }
}
