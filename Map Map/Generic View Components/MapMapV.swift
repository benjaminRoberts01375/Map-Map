//
//  MapMapV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/15/23.
//

import SwiftUI

struct MapMapV: View {
    @ObservedObject var mapMap: MapMap
    let mapMapImageType: MapType
    @State var mapMapImage: MapMapImage?
    @State var mapMapImageStatus: MapMapImage.ImageStatus?
    
    init(_ mapMap: MapMap, imageType: MapType) {
        self.mapMap = mapMap
        self.mapMapImageType = imageType
        getMapFromType(imageType)
    }
    
    /// What photo should be rendered for this MapMap
    public enum MapType {
        /// Thumbnail image.
        case thumbnail
        /// Full size MapMap with edits.
        case image
        /// Unedited original MapMap image.
        case originalThumbnail
        /// Unedited original Map Map thumbnail
        case originalImage
    }
    
    var body: some View {
        VStack {
            switch mapMapImageStatus {
            case .empty:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                    .task { await mapMapImage?.loadFromCD() }
                    .onAppear { print("Empty") }
            case .loading, .none:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                    .onAppear { print("Loading/none") }
            case .failure:
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.yellow)
                    .accessibilityLabel("Could not load Map Map")
                    .onAppear { print("Failed") }
            case .successful(let uiImage):
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .accessibilityLabel(mapMap.mapMapName ?? "Map Map")
                    .onAppear { print("Successful") }
            }
        }
        .onChange(of: mapMap.unwrappedMapMapImageContainers.count) {
            getMapFromType(mapMapImageType)
        }
        .onChange(of: mapMapImageStatus) { getMapFromType(mapMapImageType) }
    }
    
    private func getMapFromType(_ mapType: MapType) {
        switch mapType {
        case .image:
            mapMapImage = mapMap.unwrappedMapMapImageContainers.first?.unwrappedImages.last
            mapMapImageStatus = mapMapImage?.imageStatus
        case .thumbnail:
            mapMapImage = mapMap.unwrappedMapMapImageContainers.first?.unwrappedImages.last
            mapMapImageStatus = mapMapImage?.thumbnailStatus
        case .originalImage:
            mapMapImage = mapMap.unwrappedMapMapImageContainers.first?.unwrappedImages.first
            mapMapImageStatus = mapMapImage?.imageStatus
        case .originalThumbnail:
            mapMapImage = mapMap.unwrappedMapMapImageContainers.first?.unwrappedImages.first
            mapMapImageStatus = mapMapImage?.thumbnailStatus
        }
    }
}
