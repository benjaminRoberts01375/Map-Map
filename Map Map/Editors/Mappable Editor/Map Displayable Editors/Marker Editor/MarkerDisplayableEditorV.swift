//
//  MarkerDisplayableEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 4/30/24.
//

import MapKit
import SwiftUI

struct MarkerDisplayableEditorV: View {
    @Environment(MapDetailsM.self) var mapDetails
    @ObservedObject var marker: Marker
    /// Track if the marker's angle should be saved.
    @State private var saveAngle: Bool = true
    /// All available MapMaps
    @FetchRequest(sortDescriptors: []) var mapMaps: FetchedResults<MapMap>
    
    var body: some View {
        GeometryReader { geo in
            MapDisplayableEditorV(editing: marker, additionalSaveAction: updateMarker, actionButtons: [
                ColorPicker("", selection: $marker.backgroundColor, supportsOpacity: false).labelsHidden(),
                SymbolPickerButtonV(marker: marker, height: geo.size.height)
            ]) {
                MarkerV(marker: marker)
                    .frame(width: MarkerV.iconSize, height: MarkerV.iconSize)
            }
        }
    }
    
    /// Determine all MapMaps that overlap a given Marker
    /// - Parameters:
    ///   - mapDetails: A struct holding information about the map.
    ///   - mapContext: A `MapProxy` that is generated by a `MapReader` to allow for mapping of lat/long coordinates to screen-space.
    ///   - mapMaps: All available MapMaps.
    /// - Returns: If the Marker's position in screen-space was not found, then nil is returned.
    /// Otherwise, all available MapMaps are returned.
    public static func markerOverMapMaps(
        _ marker: Marker,
        mapDetails: MapDetailsM,
        mapMaps: FetchedResults<MapMap>
    ) -> [MapMap]? {
        guard let mapContext = mapDetails.mapProxy,
              let markerPosition = mapContext.convert(marker.coordinate, to: .global)
        else { return nil }
        let marker = CGPath(
            rect: CGRect(origin: markerPosition, size: CGSize(width: MarkerV.iconSize, height: MarkerV.iconSize)),
            transform: .none
        )
        var overlappingMapMaps: [MapMap] = []
        for mapMap in mapMaps {
            if let mapMapImage = mapMap.activeImage,
               let mapMapBounds = MapV.generateMapMapRotatedConvexHull(
                mapMapImage: mapMapImage,
                mapDetails: mapDetails,
                mapContext: mapContext
               )?.cgPath,
               mapMapBounds.intersects(marker) {
                overlappingMapMaps.append(mapMap)
            }
        }
        return overlappingMapMaps
    }
    
    /// Check if the marker overlaps a Map Map.
    func determineMarkerOverlap() {
        if let overlappingMapMaps = Self.markerOverMapMaps(marker, mapDetails: mapDetails, mapMaps: mapMaps) {
            // Remove current marker from all MapMaps
            for mapMap in marker.formattedMapMaps { mapMap.removeFromMarkers(marker) }
            // Add Marker to relevant MapMaps
            for mapMap in overlappingMapMaps { mapMap.addToMarkers(marker) }
        }
    }
    
    /// Update the marker to the current status of the Marker Editor.
    private func updateMarker() {
        marker.coordinate = mapDetails.region.center
        marker.lockRotationAngleDouble = saveAngle ? -mapDetails.mapCamera.heading : nil
        determineMarkerOverlap()
        marker.endEditing()
    }
}
