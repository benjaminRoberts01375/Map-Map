//
//  ContentView.swift
//  Map Map
//
//  Created by Ben Roberts on 9/13/23.
//

import AlertToast
import Bottom_Drawer
import CoreData
import SwiftUI

struct ContentView: View {
    @FetchRequest(sortDescriptors: []) var mapMaps: FetchedResults<MapMap>
    @FetchRequest(sortDescriptors: []) var markers: FetchedResults<Marker>
    @Environment(\.managedObjectContext) var moc
    @State var editingMapMap: Bool = false
    @State var editingMarker: Bool = false
    @State var toastInfo: ToastInfo = ToastInfo()
    @State var displayType: LocationDisplayMode = .degrees
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                BackgroundMapLayersV(displayType: $displayType)
                if editingMapMap {
                    if let mapInProgress = mapMaps.first(where: { $0.isEditing }) {
                        MapMapEditor(mapMap: mapInProgress)
                    }
                    else { EmptyView().onAppear { editingMapMap = false } }
                }
                else if editingMarker {
                    if let markerInProgress = markers.first(where: { $0.isEditing }) {
                        MarkerEditorV(marker: markerInProgress)
                    }
                }
                else {
                    BottomDrawer(
                        verticalDetents: [.medium, .large, .header],
                        horizontalDetents: [.left, .right],
                        shortCardSize: 315,
                        header: { _ in DefaultDrawerHeaderV() },
                        content: { isShortCard in
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
            editingMapMap = mapMaps.contains(where: { $0.isEditing })
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
            for marker in markers {
                if marker.isEditing { marker.isEditing = false }
            }
            try? moc.save()
        }
    }
}

#Preview {
    ContentView()
}
