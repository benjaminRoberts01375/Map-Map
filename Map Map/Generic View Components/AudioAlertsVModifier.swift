//
//  AudioAlertsVModifier.swift
//  Map Map
//
//  Created by Ben Roberts on 1/30/24.
//

import MapKit
import SwiftUI

struct AudioAlertsVModifier: ViewModifier {
    @AppStorage(UserDefaults.kAudioAlerts) private var audioAlerts = UserDefaults.dAudioAlerts
    @FetchRequest(sortDescriptors: []) private var markers: FetchedResults<Marker>
    @State private var inRadiusOfMarkers: [Marker] = []
    @State private var checkTimer: Timer?
    @State private var locationsHandler = LocationsHandler.shared
    static let markerAlertRadius: Measurement<UnitLength> = Measurement(value: 200, unit: .meters)
    
    func body(content: Content) -> some View {
        content
            .onAppear { locationsHandler.startLocationTracking() }
            .onChange(of: locationsHandler.lastLocation) { _, update in
                for marker in markers {
                    let markerPos = CLLocation(latitude: marker.coordinates.latitude, longitude: marker.coordinates.longitude)
                    let distance: Measurement<UnitLength> = Measurement(value: markerPos.distance(from: update), unit: .meters)
                    // Just entered range of new marker
                    if distance <= AudioAlertsVModifier.markerAlertRadius && !inRadiusOfMarkers.contains(marker) {
                        // TODO: Alert user
                    }
                    // Just left range of marker
                    else if distance > AudioAlertsVModifier.markerAlertRadius && inRadiusOfMarkers.contains(marker) {
                        inRadiusOfMarkers.removeAll(where: { $0 == marker })
                    }
                }
            }
    }
}

extension View {
    func audioAlertsView() -> some View {
        return modifier(AudioAlertsVModifier())
    }
}
