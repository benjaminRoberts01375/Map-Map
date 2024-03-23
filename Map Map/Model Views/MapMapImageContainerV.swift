//
//  MapMapImageContainerV.swift
//  Map Map
//
//  Created by Ben Roberts on 3/23/24.
//

import SwiftUI

extension MapMapV {
    internal struct MapMapImageContainerV: View {
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
}
