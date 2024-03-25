//
//  MapMapImageV.swift
//  Map Map
//
//  Created by Ben Roberts on 3/23/24.
//

import SwiftUI

extension MapMapV {
    enum MapMapImageSize { case thumbnail, full }
    
    internal struct MapMapImageV: View {
        /// MapMap image to render
        @ObservedObject var image: MapMapImage
        /// Kind of image to render.
        let imageType: MapMapImageSize
        /// Name of parent map map.
        let name: String
        
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
}
