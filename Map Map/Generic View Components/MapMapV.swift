//
//  MapMapV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/15/23.
//

import SwiftUI

/// Simple renderer for MapMaps
struct MapMapV: View {
    /// MapMap being rendered.
    @ObservedObject var mapMap: FetchedResults<MapMap>.Element
    /// Type of MapMap photo.
    let mapType: MapType
    /// Status of the displayable map map.
    @State private var status: MapImage.ImageStatus? = .loading
    
    /// What photo should be rendered for this MapMap
    public enum MapType {
        /// Thumbnail image.
        case thumbnail
        /// Full size MapMap with edits.
        case fullImage
        /// Unedited original MapMap image.
        case original
    }
    
    var body: some View {
        VStack {
            switch status {
            case .empty:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                    .task { mapMap.activeImage?.loadImageFromCD() }
            case .loading:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
            case .success(let img):
                img
                    .resizable()
                    .scaledToFit()
                    .accessibilityLabel(mapMap.mapMapName ?? "Map Map")
            case .failure, .none:
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.yellow)
                    .accessibilityLabel("Could not load Map Map")
            }
        }
        .onChange(of: mapMap.imageCropped, initial: true) { status = getMapFromType(mapType) }
        .onChange(of: mapMap.imageDefault) { status = getMapFromType(mapType) }
    }
    
    // swiftlint:disable accessibility_label_for_image
    private func getMapFromType(_ mapType: MapType) -> MapImage.ImageStatus? {
        switch mapType {
        case .fullImage:
            return mapMap.activeImage?.image
        case .thumbnail:
            return mapMap.activeImage?.thumbnail
        case .original:
            guard let mapData = mapMap.imageDefault?.imageData,
                  let uiImage = UIImage(data: mapData)
            else { return .failure }
            return .success(Image(uiImage: uiImage))
        }
    }
    // swiftlint:enable accessibility_label_for_image
}
