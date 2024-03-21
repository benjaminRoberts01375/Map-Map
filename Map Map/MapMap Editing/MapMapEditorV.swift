//
//  MapEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/9/23.
//

import Bottom_Drawer
import MapKit
import SwiftUI

/// One-stop-shop for editing MapMaps.
struct MapMapEditor: View {
    /// MapMap being edited.
    @ObservedObject var mapMap: FetchedResults<MapMap>.Element
    /// Details about the map being plotted on.
    @Environment(MapDetailsM.self) private var mapDetails
    /// Current Managed Object Context.
    @Environment(\.managedObjectContext) private var moc
    /// Desired name for the current MapMap.
    @State private var workingName: String = ""
    /// Placement of the MapMap.
    @State private var mapMapPosition: CGRect = .zero
    /// Tracker for showing the photo (not MapMap) editor.
    @State private var showingPhotoEditor = false
    /// Tracker for showing the Markup editor.
    @State private var showingMarkupEditor = false
    /// Show this alert if there's a drawing and the user wants to crop afterwards.
    @State private var showingPhotoEditorAlert = false
    /// All available markers.
    @FetchRequest(sortDescriptors: []) var markers: FetchedResults<Marker>
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                MapMapV(mapMap, imageType: .image)
                    .onViewResizes { mapMapPosition = CGRect(origin: CGPoint(size: geo.size / 2), size: $1) }
                    .frame(width: geo.size.width * 0.75, height: geo.size.height * 0.75)
                    .opacity(0.5)
                    .allowsHitTesting(false)
                    .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
                    .offset(y: -7)
            }
            .ignoresSafeArea()
            
            BottomDrawer(verticalDetents: [.content], horizontalDetents: [.center], shortCardSize: 350) { isShortCard in
                VStack {
                    HStack {
                        TextField("Map Map name", text: $workingName)
                            .padding(.all, 5)
                            .background(Color.gray.opacity(0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .frame(width: 205)
                        Button(action: {
                            if mapMap.activeImage?.drawing == nil { showingPhotoEditor = true } // Drawing exists
                            else { showingPhotoEditorAlert = true } // No drawing
                        }, label: {
                            Image(systemName: "crop")
                                .accessibilityLabel("Crop MapMap Button")
                                .padding(4)
                                .background(.gray)
                                .clipShape(Circle())
                        })
                        .buttonStyle(.plain)
                        Button(action: {
                            showingMarkupEditor = true
                        }, label: {
                            Image(systemName: "pencil.tip.crop.circle.fill")
                                .accessibilityLabel("Markup MapMap")
                                .padding(4)
                                .background(.gray)
                                .clipShape(Circle())
                        })
                        .buttonStyle(.plain)
                    }
                    HStack {
                        Button(
                            action: { updateMapMapInfo() },
                            label: { Text("Done").bigButton(backgroundColor: .blue) }
                        )
                        Button(action: {
                            if mapMap.isSetup { moc.reset() }
                            else { moc.delete(mapMap) }
                        }, label: {
                            Text("Cancel")
                                .bigButton(backgroundColor: .gray)
                        })
                        if mapMap.isSetup {
                            Button( action: {
                                moc.delete(mapMap)
                                try? moc.save()
                            }, label: {
                                Text("Delete")
                            })
                            .bigButton(backgroundColor: .red)
                        }
                    }
                }
                .padding(.bottom, isShortCard ? 0 : 10)
            }
        }
        .onAppear {
            mapDetails.preventFollowingUser()
            workingName = mapMap.displayName
        }
        .fullScreenCover(isPresented: $showingPhotoEditor) { PhotoEditorCompositeV(mapMap: mapMap) }
        .fullScreenCover(isPresented: $showingMarkupEditor) { MarkupEditorSwitcherV(mapMap: mapMap) }
        .alert(isPresented: $showingPhotoEditorAlert) {
            Alert(
                title: Text("Map Map Drawing"),
                message: Text("To change the shape of you Map Map, you must delete your drawing."),
                primaryButton: .destructive(
                    Text("Delete and Crop"),
                    action: { if let drawing = mapMap.activeImage?.drawing { moc.delete(drawing) } }
                ),
                secondaryButton: .cancel(Text("Cancel"))
            )
        }
    }
    
    /// Determine all Markers that overlap a given MapMap
    /// - Parameters:
    ///   - mapMap: MapMap to check Marker positions against.
    ///   - mapDetails: Details about the map.
    ///   - mapContext: A `MapProxy` that is generated by a `MapReader` to allow for mapping of lat/long coordinates to screen-space.
    /// - Returns: If the MapMap's position in screen-space was not found, then nil is returned.
    /// Otherwise, all available Markers are returned.
    public static func mapMapOverMarkers(_ mapMapImage: MapMapImage, mapDetails: MapDetailsM, mapContext: MapProxy) -> [Marker]? {
        guard let mapMapBounds = MapV.generateMapMapRotatedConvexHull(
            mapMapImage: mapMapImage,
            mapDetails: mapDetails,
            mapContext: mapContext
        )?.cgPath
        else { return nil }
        var markers: [Marker] = []
        
        for marker in markers {
            if let markerPosition = mapContext.convert(marker.coordinate, to: .global) {
                let markerBounds = MarkerEditorV.generateMarkerBoundingBox(markerPosition: markerPosition)
                if mapMapBounds.intersects(markerBounds) {
                    markers.append(marker)
                }
            }
        }
        return markers
    }
    
    /// Updates Map Map information based on the current state of the editor.
    private func updateMapMapInfo() {
        mapMap.coordinate = mapDetails.region.center
        mapMap.mapRotation = -mapDetails.mapCamera.heading
        mapMap.scale = mapMapPosition.width * mapDetails.mapCamera.distance
        mapMap.name = workingName
        mapMap.mapDistance = mapDetails.mapCamera.distance
        mapMap.isEditing = false
        mapMap.isSetup = true
        if let mapProxy = mapDetails.mapProxy,
            let mapMapImage = mapMap.activeImage,
            let overlappingMarkers = MapMapEditor.mapMapOverMarkers(
                mapMapImage,
                mapDetails: mapDetails,
                mapContext: mapProxy
            ) {
            for marker in mapMap.unwrappedMarkers { mapMap.removeFromMarkers(marker) } // Remove MapMap from all Markers
            for marker in overlappingMarkers { mapMap.addToMarkers(marker) } // Add MapMap to all
        }
        try? moc.save()
    }
}
