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
import StoreKit
import SwiftUI

/// First displayed view in MapMap
struct ContentView: View {
    /// All available MapMaps
    @FetchRequest(sortDescriptors: []) private var mapMaps: FetchedResults<MapMap>
    /// All available GPS Maps
    @FetchRequest(sortDescriptors: []) private var gpsMaps: FetchedResults<GPSMap>
    /// All available Markers
    @FetchRequest(sortDescriptors: []) private var markers: FetchedResults<Marker>
    /// Control if the satellite map is shown.
    @AppStorage(UserDefaults.kShowSatelliteMap) var mapType = UserDefaults.dShowSatelliteMap
    /// Current coloring of the UI elements
    @Environment(\.colorScheme) var colorScheme
    /// Current Core Data managed object context.
    @Environment(\.managedObjectContext) var moc
    /// Non-view data model
    @State var viewModel: ViewModel = ViewModel()
    
    var body: some View {
        ZStack(alignment: .top) {
            MapLayersV(editor: $viewModel.editing)
                .onDrop(of: [.image], isTargeted: $viewModel.dragAndDropTargeted) { dropImage(providers: $0) }
            
            if viewModel.dragAndDropTargeted {
                Color.black
                    .opacity(viewModel.shadeOpacity)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true))
                    .onAppear { withAnimation { viewModel.shadeOpacity = 0.25 } }
                    .onDisappear { withAnimation { viewModel.shadeOpacity = 0 } }
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
            }
            switch viewModel.editing {
            case .mapMap(let mapMap): MapMapEditor(mapMap: mapMap)
            case .gpsMap(let gpsMap): GPSMapPhaseController(gpsMap: gpsMap)
            case .marker(let marker): MarkerEditorV(marker: marker)
            case .measurement: MapMeasurementCoordinateEditorV(editing: $viewModel.editing)
            case .nothing:
                BottomDrawer(
                    verticalDetents: [.medium, .large, .header],
                    horizontalDetents: [.left, .right],
                    shortCardSize: 315,
                    header: { _ in DefaultDrawerHeaderV() },
                    content: { _ in
                        MapMapList()
                            .padding(.horizontal)
                    }
                )
            }
        }
        .toast(isPresenting: $viewModel.toastInfo.showing, tapToDismiss: false) {
            AlertToast(displayMode: .hud, type: .loading, title: "Saving", subTitle: viewModel.toastInfo.info)
        }
        .onReceive(NotificationCenter.default.publisher(for: .editingDataBlock)) { notification in
            if let editableData = notification.object as? MapMap {
                viewModel.editing = editableData.isEditing ? .mapMap(editableData) : .nothing
            }
            else if let editableData = notification.object as? GPSMap {
                viewModel.editing = editableData.isEditing ? .gpsMap(editableData) : .nothing
            }
            else if let editableData = notification.object as? Marker {
                viewModel.editing = editableData.isEditing ? .marker(editableData) : .nothing
            }
            else { viewModel.editing = .nothing }
        }
        .onReceive(NotificationCenter.default.publisher(for: .savingToastNotification)) { notification in
            if let showing = notification.userInfo?["savingVal"] as? Bool {
                viewModel.toastInfo.showing = showing
            }
            if let info = notification.userInfo?["name"] as? String {
                viewModel.toastInfo.info = info
            }
        }
        .audioAlerts()
        .environment(\.colorScheme, mapType ? .dark : colorScheme)
        .onAppear {
            if !AddMapMapTip.discovered { // Update adding a Map Map tip
                Timer.scheduledTimer(withTimeInterval: 15, repeats: false) { _ in
                    AddMapMapTip.discovered = true
                }
            }
            Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in // Update using the HUD tip
                Task { await UseHUDTip.count.donate() }
            }
        }
    }
}

#Preview { ContentView() }
