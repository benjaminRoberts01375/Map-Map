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
    /// Current Core Data managed object context.
    @Environment(\.managedObjectContext) private var moc
    /// Object being edited
    @State var editing: Editor = .nothing
    /// Information to display in a Toast notification.
    @State private var toastInfo: ToastInfo = ToastInfo()
    /// Coordinate display type.
    @State private var displayType: LocationDisplayMode = .degrees
    
    var body: some View {
        MapReader { mapContext in
            ZStack(alignment: .top) {
                BackgroundMapLayersV(displayType: $displayType, editor: $editing, mapContext: mapContext)
                    .environment(\.locationDisplayMode, displayType)
                switch editing {
                case .mapMap(let mapMap): MapMapEditor(mapMap: mapMap, mapContext: mapContext)
                case .marker(let marker): MarkerEditorV(marker: marker, mapContext: mapContext)
                case .measurement: MeasurementEditorV(editing: $editing, mapContext: mapContext)
                case .nothing:
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
            switch self.editing {
            case .measurement: return
            default:
                if let editingMapMap = mapMaps.first(where: { $0.isEditing }) { self.editing = .mapMap(editingMapMap) }
                else if let editingMarker = markers.first(where: { $0.isEditing }) { self.editing = .marker(editingMarker) }
                else { self.editing = .nothing }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .savingToastNotification)) { notification in
            if let showing = notification.userInfo?["savingVal"] as? Bool {
                toastInfo.showing = showing
            }
            if let info = notification.userInfo?["name"] as? String {
                toastInfo.info = info
            }
        }
    }
}

#Preview {
    ContentView()
}
