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
    
    enum MapMapImageType {
        case image, thumbnail, originalImage, originalThumbnail
    }
    
    var body: some View {
        if let container = self.mapMap.unwrappedMapMapImageContainers.first {
            MapMapImageContainerV(container, imageType: imageType, name: mapMap.displayName)
        }
        else { MapMapImageFailedV() }
    }
}
