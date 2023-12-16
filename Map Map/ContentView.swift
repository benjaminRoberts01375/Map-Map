//
//  ContentView.swift
//  Map Map
//
//  Created by Ben Roberts on 9/13/23.
//

import AlertToast
import Bottom_Drawer
import CoreData
import MapKit
import SwiftUI

/// First displayed view in MapMap
struct ContentView: View {
    /// All available MapMaps
    @FetchRequest(sortDescriptors: []) private var mapMaps: FetchedResults<MapMap>
    /// All available Markers
    @FetchRequest(sortDescriptors: []) private var markers: FetchedResults<Marker>
    /// All available Measurements
    @FetchRequest(sortDescriptors: []) private var measurements: FetchedResults<MapMeasurement>
    /// Current Core Data managed object context.
    @Environment(\.managedObjectContext) private var moc
    /// MapMap being edited.
    @State private var editingMapMap: MapMap?
    /// Marker being edited.
    @State private var editingMarker: Marker?
    /// Measurement being edited.
    @State private var editingMeasurement: MapMeasurement?
    /// Information to display in a Toast notification.
    @State private var toastInfo: ToastInfo = ToastInfo()
    /// Coordinate display type.
    @State private var displayType: LocationDisplayMode = .degrees
    
    var body: some View {
        MapReader { mapContext in
            ZStack(alignment: .top) {
                BackgroundMapLayersV(displayType: $displayType, mapContext: mapContext)
                    .environment(\.locationDisplayMode, displayType)
                if let editingMapMap = editingMapMap {
                    MapMapEditor(mapMap: editingMapMap)
                }
                else if let editingMarker = editingMarker {
                    MarkerEditorV(marker: editingMarker)
                }
                else if let editingMeasurement = editingMeasurement {
                    MeasurementEditorV(measurement: editingMeasurement, mapContext: mapContext)
                }
                else {
                    BottomDrawer(
                        verticalDetents: [.medium, .large, .header],
                        horizontalDetents: [.left, .right],
                        shortCardSize: 315,
                        header: { _ in DefaultDrawerHeaderV() },
                        content: { _ in
                            MapMapList()
                                .environment(\.locationDisplayMode, displayType)
                                .padding(.horizontal)
                        }
                    )
                }
            }
        }
        .toast(isPresenting: $toastInfo.showing, tapToDismiss: false, alert: {
            AlertToast(displayMode: .hud, type: .loading, title: "Saving", subTitle: toastInfo.info)
        })
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange)) { _ in
            let editingMapMap = mapMaps.first(where: { $0.isEditing })
            if self.editingMapMap != editingMapMap { self.editingMapMap = editingMapMap }
            let editingMarker = markers.first(where: { $0.isEditing })
            if self.editingMarker != editingMarker { self.editingMarker = editingMarker }
            let editingMeasurement = measurements.first(where: { $0.isEditing })
            if self.editingMeasurement != editingMeasurement { self.editingMeasurement = editingMeasurement }
        }
        .onReceive(NotificationCenter.default.publisher(for: .savingToastNotification)) { notification in
            if let showing = notification.userInfo?["savingVal"] as? Bool {
                toastInfo.showing = showing
            }
            if let info = notification.userInfo?["name"] as? String {
                toastInfo.info = info
            }
        }
        .task {
            for mapMap in mapMaps {
                if !mapMap.isSetup { moc.delete(mapMap) }
                else if mapMap.isEditing == true { mapMap.isEditing = false }
            }
            for marker in markers where marker.isEditing {
                marker.isEditing = false
            }
            try? moc.save()
        }
    }
}

#Preview {
    ContentView()
}
