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
            case .mapMap(let mapMap): MapMapMapDisplayableEditorV(mapMap: mapMap)
            case .gpsMap(let gpsMap): GPSMapPhaseController(gpsMap: gpsMap)
            case .marker(let marker): MarkerDisplayableEditorV(marker: marker)
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
        .onReceive(NotificationCenter.default.publisher(for: .editingDataBlock)) { self.editingDataBlock(notification: $0) }
        .onReceive(NotificationCenter.default.publisher(for: .savingToastNotification)) { self.savingToastNotification(notification: $0) }
        .audioAlerts()
        .environment(\.colorScheme, mapType ? .dark : colorScheme)
        .onAppear { tipSetup() }
    }
}

#Preview { ContentView() }
