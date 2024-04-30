//
//  MapMapEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 4/30/24.
//

import MapKit
import SwiftUI

struct MapMapMapDisplayableEditorV: View {
    @ObservedObject var mapMap: MapMap
    @State var mapMapPosition: CGRect = .zero
    @Environment(MapDetailsM.self) var mapDetails
    /// Tracker for showing the photo (not MapMap) editor.
    @State private var showingPhotoEditor = false
    /// Tracker for showing the Markup editor.
    @State private var showingMarkupEditor = false
    /// Show this alert if there's a drawing and the user wants to crop afterwards.
    @State private var showingPhotoEditorAlert = false
    /// All available markers.
    @FetchRequest(sortDescriptors: []) var markers: FetchedResults<Marker>
    
    var body: some View {
        MapDisplayableEditorV(editing: mapMap, additionalSaveAction: updateMapMapInfo, actionButtons: [
            MapDisplayableEditorV.EditorButton(systemImage: "crop.rotate", label: "Crop Map Map", action: openCropEditor),
            MapDisplayableEditorV.EditorButton(systemImage: "pencil.tip", label: "Markup Map Map") { showingMarkupEditor = true }
        ]) {
            GeometryReader { geo in
                MapMapV(mapMap, imageType: .image)
                    .onViewResizes { mapMapPosition = CGRect(origin: CGPoint(size: geo.size / 2), size: $1) }
                    .frame(width: geo.size.width * 0.75, height: geo.size.height * 0.75)
                    .opacity(0.5)
                    .allowsHitTesting(false)
                    .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
                    .offset(y: -7)
            }
        }
        .fullScreenCover(isPresented: $showingPhotoEditor) { PhotoEditorCompositeV(mapMap: mapMap) }
        .fullScreenCover(isPresented: $showingMarkupEditor) { MarkupEditorSwitcherV(mapMap: mapMap) }
        .deleteMapMapImageDrawing(mapMap.activeImage, isPresented: $showingPhotoEditorAlert)
    }
    
    /// Determine all Markers that overlap a given MapMap
    /// - Parameters:
    ///   - mapMapImage: Image to check bounds of, and check Markers against.
    /// - Returns: If the MapMap's position in screen-space was not found, then nil is returned.
    /// Otherwise, all available Markers are returned.
    private func mapMapOverMarkers(_ mapMapImage: MapMapImage) -> [Marker]? {
        guard let mapContext = mapDetails.mapProxy,
              let mapMapBounds = MapV.generateMapMapRotatedConvexHull(
                mapMapImage: mapMapImage,
                mapDetails: mapDetails,
                mapContext: mapContext
              )?.cgPath
        else { return nil }
        var layeredMarkers: [Marker] = []
        
        for marker in markers {
            if let markerPosition = mapContext.convert(marker.coordinate, to: .global) {
                let markerBounds = CGPath(
                    rect: CGRect(origin: markerPosition, size: CGSize(width: MarkerV.iconSize, height: MarkerV.iconSize)),
                    transform: .none
                )
                if mapMapBounds.intersects(markerBounds) {
                    layeredMarkers.append(marker)
                }
            }
        }
        return layeredMarkers
    }
    
    /// Updates Map Map information based on the current state of the editor.
    private func updateMapMapInfo() {
        mapMap.coordinate = mapDetails.region.center
        mapMap.mapRotation = -mapDetails.mapCamera.heading
        mapMap.scale = mapMapPosition.width * mapDetails.mapCamera.distance
        mapMap.mapDistance = mapDetails.mapCamera.distance
        mapMap.endEditing()
        mapMap.isSetup = true
        if let mapMapImage = mapMap.activeImage,
            let overlappingMarkers = mapMapOverMarkers(mapMapImage) {
            for marker in mapMap.unwrappedMarkers { mapMap.removeFromMarkers(marker) } // Remove MapMap from all Markers
            for marker in overlappingMarkers { mapMap.addToMarkers(marker) } // Add MapMap to all
        }
    }
    
    private func openCropEditor() {
        if mapMap.activeImage?.drawing == nil { showingPhotoEditor = true } // Drawing exists
        else { showingPhotoEditorAlert = true } // No drawing
    }
}
