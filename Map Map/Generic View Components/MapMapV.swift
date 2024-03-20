//
//  MapMapV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/15/23.
//

import SwiftUI

struct MapMapV: View {
    @ObservedObject var mapMap: MapMap
    let imageType: MapMapImageType
    
    init(_ mapMap: MapMap, imageType: MapMapImageType) {
        self.mapMap = mapMap
        self.imageType = imageType
    }
    
    var body: some View {
        if let container = self.mapMap.unwrappedMapMapImageContainers.first { MapMapImageContainerV(container, imageType: imageType) }
        else { MapMapImageFailedV() }
    }
}

fileprivate struct MapMapImageContainerV: View {
    @ObservedObject var container: MapMapImageContainer
    let imageType: MapMapImageType
    
    init(_ container: MapMapImageContainer, imageType: MapMapImageType) {
        self.container = container
        self.imageType = imageType
    }
    
    var body: some View {
        switch imageType {
        case .image:
            if let mapMapImage = container.unwrappedImages.last { MapMapImageV(image: mapMapImage, imageSize: .full) }
            else { MapMapImageFailedV() }
        case .thumbnail:
            if let mapMapImage = container.unwrappedImages.last { MapMapImageV(image: mapMapImage, imageSize: .thumbnail) }
            else { MapMapImageFailedV() }
        case .originalImage:
            if let mapMapImage = container.unwrappedImages.first { MapMapImageV(image: mapMapImage, imageSize: .full) }
            else { MapMapImageFailedV() }
        case .originalThumbnail:
            if let mapMapImage = container.unwrappedImages.first { MapMapImageV(image: mapMapImage, imageSize: .thumbnail) }
            else { MapMapImageFailedV() }
        }
    }
}

fileprivate struct MapMapImageV: View {
    @ObservedObject var image: MapMapImage
    let imageSize: MapMapImageSize
    
    enum MapMapImageSize {
        case thumbnail, full
    }
    
    var body: some View {
        switch imageSize {
        case .thumbnail:
            switch image.thumbnailStatus {
            case .empty:
                MapMapImageLoading()
                    .task { await image.loadFromCD() }
            case .loading:
                MapMapImageLoading()
            case .successful(let uIImage):
                MapMapImageSuccessful(image: uIImage)
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
                MapMapImageSuccessful(image: uIImage)
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
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
//            .accessibilityLabel(mapMap.mapMapName ?? MapMap.defaultName)
    }
}

enum MapMapImageType {
    case image, thumbnail, originalImage, originalThumbnail
}
