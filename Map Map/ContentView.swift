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
    /// Details for the main map.
    @Environment(MapDetailsM.self) private var mapDetails
    /// Object being edited
    @State var editing: Editor = .nothing
    /// Information to display in a Toast notification.
    @State private var toastInfo: ToastInfo = ToastInfo()
    /// Track if a drag and drop action may occur on this view.
    @State private var dragAndDropTargeted: Bool = false
    /// Control the opacity of the dark shade overlay.
    @State private var shadeOpacity: CGFloat = 0
    
    var body: some View {
        MapReader { mapContext in
            ZStack(alignment: .top) {
                ZStack {
                    MapLayersV(editor: $editing)
                        .onDrop(of: [.image], isTargeted: $dragAndDropTargeted) { dropImage(providers: $0) }
                    
                    if dragAndDropTargeted {
                        Color.black
                            .opacity(shadeOpacity)
                            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true))
                            .onAppear { withAnimation { shadeOpacity = 0.25 } }
                            .onDisappear { withAnimation { shadeOpacity = 0 } }
                            .allowsHitTesting(false)
                            .ignoresSafeArea()
                    }
                }
                switch editing {
                case .mapMap(let mapMap): MapMapEditor(mapMap: mapMap)
                case .marker(let marker): MarkerEditorV(marker: marker)
                case .measurement: MeasurementEditorV(editing: $editing)
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
            .onAppear { mapDetails.mapProxy = mapContext }
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
        .audioAlerts()
    }
    
    /// Handles drag and drop of images from outside of Map Map.
    /// - Parameter providers: All arguments given from drag and drop.
    /// - Returns: Success boolean.
    private func dropImage(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first
        else { return false }
        if !provider.hasItemConformingToTypeIdentifier("public.image") { return false }
        _ = provider.loadObject(ofClass: UIImage.self) { image, _ in
            guard let image = image as? UIImage
            else { return }
            DispatchQueue.main.async { _ = MapMap(uiPhoto: image, moc: moc) }
        }
        return true
    }
}

#Preview {
    ContentView()
}
