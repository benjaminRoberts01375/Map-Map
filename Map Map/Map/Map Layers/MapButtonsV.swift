//
//  MapButtonsV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/19/23.
//

import MapKit
import SwiftUI

/// Map button controls.
struct MapButtonsV: View {
    /// All available MapMaps
    @FetchRequest(sortDescriptors: []) private var mapMaps: FetchedResults<MapMap>
    /// All available Markers
    @FetchRequest(sortDescriptors: []) private var markers: FetchedResults<Marker>
    /// All available Map Measurement Coordiantes
    @FetchRequest(sortDescriptors: []) private var measurements: FetchedResults<MapMeasurementCoordinate>
    /// Current Core Data managed object context.
    @Environment(\.managedObjectContext) private var moc
    /// Details about the map.
    @Environment(MapDetailsM.self) private var mapDetails
    /// Control if enabled Markers are allowed to chirp
    @AppStorage(UserDefaults.kAudioAlerts) var markersChirp = UserDefaults.dAudioAlerts
    /// Tracker for adding or removing markers.
    @State private var markerButton: MarkerButtonType = .add
    /// Track showing and hiding the marker chirp button
    @State var showMarkerChipButton: Bool = false
    /// Track if the popover for showing the marker chirp keep open popover.
    @State var showMarkerChirpKeepOpen: Bool = false
    /// Current editor being used.
    @Binding var editor: Editor
    /// Size of parent view.
    let screenSize: CGSize
    /// Map ID.
    let mapScope: Namespace.ID
    
    /// Type for tracking adding or removing markers.
    enum MarkerButtonType: Equatable {
        /// Potentially add a Marker
        case add
        /// Potentially delete this Marker.
        case delete(Marker)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack {
                MapHudV()
                MapScaleView(scope: mapScope)
            }
            .padding(.trailing, MapLayersV.minSafeAreaDistance)
            .background {
                BlurView()
                    .blur(radius: MapLayersV.blurAmount)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
            VStack {
                MapUserLocationButton(scope: mapScope)
                    .background(.thickMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                if showMarkerChipButton {
                    Button {
                        withAnimation { markersChirp.toggle() }
                    } label: {
                        Image(systemName: markersChirp ? "speaker.wave.3.fill" : "speaker.slash")
                            .accessibilityLabel(markersChirp ? "Markers can make audio alerts." : "Markers cannot make audio alerts.")
                            .mapButton(active: markersChirp)
                    }
                    .onChange(of: markersChirp, initial: true) {
                        if markersChirp && 
                            UserDefaults.standard.integer(forKey: UserDefaults.kMarkerChirpKeepOpen) != UserDefaults.vMarkerChirp {
                            showMarkerChirpKeepOpen = true
                            UserDefaults.standard.set(UserDefaults.vMarkerChirp, forKey: UserDefaults.kMarkerChirpKeepOpen)
                        }
                    }
                    .popover(isPresented: $showMarkerChirpKeepOpen) {
                        Text("Keep Map Map open to get audio alerts.")
                            .padding()
                    }
                }
                switch markerButton {
                case .add:
                    Button {
                        addMarker()
                    } label: {
                        Image(systemName: "mappin.and.ellipse")
                            .accessibilityLabel("Add Marker Button")
                            .mapButton()
                    }
                case .delete(let marker):
                    Button {
                        moc.delete(marker)
                        try? moc.save()
                    } label: {
                        Image(systemName: "mappin.slash")
                            .accessibilityLabel("Remove Marker Button")
                            .mapButton()
                    }
                }
                Button {
                    editor = .measurement
                } label: {
                    Image(systemName: "ruler")
                        .accessibilityLabel("Edit Measurements Button")
                        .rotationEffect(Angle(degrees: -45))
                        .mapButton()
                }
                .contextMenu {
                    Button(role: .destructive) {
                        for measurement in measurements { moc.delete(measurement) }
                        try? moc.save()
                    } label: {
                        Label("Delete All Measurements", systemImage: "trash.fill")
                    }
                }
            }
            .background {
                BlurView()
                    .blur(radius: MapLayersV.blurAmount)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .animation(.easeInOut, value: markerButton)
        .mapScope(mapScope)
        .onChange(of: mapDetails.region.center) { checkOverMarker() }
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
            checkOverMarker()
        }
        .onChange(of: markers.count, initial: true) {
            withAnimation {
                if markers.isEmpty {
                    markersChirp = false
                    self.showMarkerChipButton = false
                    return
                }
                self.showMarkerChipButton = true
            }
        }
    }
    
    func checkOverMarker() {
        for marker in markers {
            if let markerPos = mapDetails.mapProxy?.convert(marker.coordinate, to: .global) {
                let xComponent = abs(markerPos.x - screenSize.width / 2)
                let yComponent = abs(markerPos.y - screenSize.height / 2)
                let distance = sqrt(pow(xComponent, 2) + pow(yComponent, 2))
                if distance < MapPointsV.iconSize / 2 {
                    markerButton = .delete(marker)
                    return
                }
            }
        }
        switch markerButton {
        case .add:
            break
        default:
            markerButton = .add
        }
    }
    
    func addMarker() {
        let newMarker = Marker(coordinate: mapDetails.region.center, insertInto: moc)
        if let mapProxy = mapDetails.mapProxy, let overlappedMapMaps = MarkerEditorV.markerOverMapMaps(
            newMarker,
            mapDetails: mapDetails,
            mapContext: mapProxy,
            mapMaps: mapMaps
        ) {
            for mapMap in overlappedMapMaps { newMarker.addToMapMap(mapMap) }
        }
        try? moc.save()
    }
}
