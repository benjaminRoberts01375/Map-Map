//
//  AudioAlertsVModifier.swift
//  Map Map
//
//  Created by Ben Roberts on 1/30/24.
//

import AVFoundation
import MapKit
import SwiftUI

struct AudioAlertsVModifier: ViewModifier {
    @AppStorage(UserDefaults.kAudioAlerts) private var audioAlerts = UserDefaults.dAudioAlerts
    @FetchRequest(sortDescriptors: []) private var markers: FetchedResults<Marker>
    @State private var inRadiusOfMarkers: [Marker] = []
    @State private var locationsHandler = LocationsHandler.shared
    let synthesizer = AVSpeechSynthesizer()
    static let markerAlertRadius: Measurement<UnitLength> = Measurement(value: 200, unit: .meters)
    
    func body(content: Content) -> some View {
        content
            .onAppear { locationsHandler.startLocationTracking() }
            .onChange(of: locationsHandler.lastLocation) { _, update in
                var newMarkers: [Marker] = []
                for marker in markers {
                    let markerPos = CLLocation(latitude: marker.coordinates.latitude, longitude: marker.coordinates.longitude)
                    let distance: Measurement<UnitLength> = Measurement(value: markerPos.distance(from: update), unit: .meters)
                    // Just entered range of new marker
                    if distance <= AudioAlertsVModifier.markerAlertRadius && !inRadiusOfMarkers.contains(marker) {
                        newMarkers.append(marker)
                        inRadiusOfMarkers.append(marker)
                    }
                    // Just left range of marker
                    else if distance > AudioAlertsVModifier.markerAlertRadius && inRadiusOfMarkers.contains(marker) {
                        inRadiusOfMarkers.removeAll(where: { $0 == marker })
                    }
                }
                if let lastMarkerName = newMarkers.last?.name {
                    var message = "Approaching "
                    if newMarkers.count > 1 {
                        for marker in newMarkers.dropLast() {
                            if let markerName = marker.name {
                                message += "\(markerName), "
                            }
                        }
                        message += "and "
                    }
                    message += lastMarkerName
                    let utterance = AVSpeechUtterance(string: message)
                    synthesizer.speak(utterance)
                }
            }
    }
}

extension View {
    func audioAlerts() -> some View {
        return modifier(AudioAlertsVModifier())
    }
}
