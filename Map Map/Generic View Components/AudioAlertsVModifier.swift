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
    /// Track if audio alerts are enabled.
    @AppStorage(UserDefaults.kAudioAlerts) private var audioAlerts = UserDefaults.dAudioAlerts
    /// Available Markers on the map.
    @FetchRequest(sortDescriptors: []) private var markers: FetchedResults<Marker>
    /// Markers currently in range of the user.
    @State private var inRadiusOfMarkers: [Marker] = []
    /// User's location.
    @State private var locationsHandler = LocationsHandler.shared
    /// Voice synthesizer for text to speach.
    let synthesizer = AVSpeechSynthesizer()
    /// Maximum distance from user to marker.
    static let markerAlertRadius: Measurement<UnitLength> = Measurement(value: 200, unit: .feet)
    
    func body(content: Content) -> some View {
        content
            .onAppear { locationsHandler.startLocationTracking() }
            .onChange(of: locationsHandler.lastLocation) {
                if audioAlerts { speakMarkerNames(markers: determineMarkersToSpeak(userLocation: $1)) }
            }
            .onChange(of: audioAlerts) { if !$1 { synthesizer.stopSpeaking(at: .immediate) } }
    }
    
    /// Determine which markers need to be read out loud.
    /// - Parameter userLocation: Current location of the user.
    /// - Returns: A list of Markers who are newly within range of the user.
    private func determineMarkersToSpeak(userLocation: CLLocation) -> [Marker] {
        var newMarkers: [Marker] = []
        for marker in markers {
            let markerPos = CLLocation(latitude: marker.coordinate.latitude, longitude: marker.coordinate.longitude)
            let distance: Measurement<UnitLength> = Measurement(value: markerPos.distance(from: userLocation), unit: .meters)
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
        return newMarkers
    }
    
    /// Speak all names of markers in a marker list.
    /// - Parameter markers: Markers to have names read for.
    private func speakMarkerNames(markers: [Marker]) {
        if let lastMarkerName = markers.last?.name {
            var message = "Approaching "
            if markers.count > 1 {
                for marker in markers.dropLast() {
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

extension View {
    /// Attach Marker audio alerts to the view.
    /// - Returns: Updated view.
    func audioAlerts() -> some View {
        return modifier(AudioAlertsVModifier())
    }
}
