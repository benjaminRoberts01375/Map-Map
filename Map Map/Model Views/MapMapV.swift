//
//  MapMapV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/15/23.
//

import SwiftUI

struct MapMapV: View {
    /// MapMap to display.
    @ObservedObject var mapMap: MapMap
    /// The kind of image to render.
    let imageType: MapMapImageType
    
    init(_ mapMap: MapMap, imageType: MapMapImageType) {
        self.mapMap = mapMap
        self.imageType = imageType
    }
    
    var body: some View {
        if let container = self.mapMap.unwrappedMapMapImageContainers.first {
            MapMapImageContainerV(container, imageType: imageType, name: mapMap.displayName)
        }
        else { MapMapImageFailedV() }
    }
}

fileprivate struct MapMapImageContainerV: View {
    /// Map Map Image container that holds image to render.
    @ObservedObject var container: MapMapImageContainer
    /// Kind of image to render.
    let imageType: MapMapImageType
    /// Map Map name
    let name: String
    
    init(_ container: MapMapImageContainer, imageType: MapMapImageType, name: String) {
        self.container = container
        self.imageType = imageType
        self.name = name
    }
    
    var body: some View {
        switch imageType {
        case .image:
            if let mapMapImage = container.unwrappedImages.last { MapMapImageV(image: mapMapImage, imageType: .full, name: name) }
            else { MapMapImageFailedV() }
        case .thumbnail:
            if let mapMapImage = container.unwrappedImages.last { MapMapImageV(image: mapMapImage, imageType: .thumbnail, name: name) }
            else { MapMapImageFailedV() }
        case .originalImage:
            if let mapMapImage = container.unwrappedImages.first { MapMapImageV(image: mapMapImage, imageType: .full, name: name) }
            else { MapMapImageFailedV() }
        case .originalThumbnail:
            if let mapMapImage = container.unwrappedImages.first { MapMapImageV(image: mapMapImage, imageType: .thumbnail, name: name) }
            else { MapMapImageFailedV() }
        }
    }
}

fileprivate struct MapMapImageV: View {
    /// MapMap image to render
    @ObservedObject var image: MapMapImage
    /// Kind of image to render.
    let imageType: MapMapImageSize
    /// Name of parent map map.
    let name: String
    
    enum MapMapImageSize {
        case thumbnail, full
    }
    
    var body: some View {
        switch imageType {
        case .thumbnail:
            switch image.thumbnailStatus {
            case .empty:
                MapMapImageLoading()
                    .task { await image.loadFromCD() }
            case .loading:
                MapMapImageLoading()
            case .successful(let uIImage):
                MapMapImageSuccessful(image: uIImage, name: name)
            case .failure:
                MapMapImageFailedV()
            }
        case .full:
            switch image.imageStatus {
            case .empty:
                MapMapImageLoading()
                    .task { await image.loadFromCD() }
            case .loading:
                MapMapImageLoading()
            case .successful(let uIImage):
                MapMapImageSuccessful(image: uIImage, name: name)
            case .failure:
                MapMapImageFailedV()
            }
        }
    }
}

fileprivate struct MapMapImageFailedV: View {
    var body: some View {
        Image(systemName: "exclamationmark.triangle.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.yellow)
            .accessibilityLabel("Could not load Map Map")
    }
}

fileprivate struct MapMapImageLoading: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
    }
}

fileprivate struct MapMapImageSuccessful: View {
    let image: UIImage
    let name: String
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .accessibilityLabel(name)
    }
}

enum MapMapImageType {
    case image, thumbnail, originalImage, originalThumbnail
}
