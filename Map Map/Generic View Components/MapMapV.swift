//
//  MapMapV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/15/23.
//

import SwiftUI

struct MapMapV: View {
    @ObservedObject var mapMap: FetchedResults<MapMap>.Element
    let mapType: MapType
    
    public enum MapType {
        case thumbnail
        case fullImage
        case original
    }
    
    var body: some View {
        VStack {
            switch getMapFromType(mapType) {
            case .empty:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                    .task {
                        mapMap.loadImageFromCD()
                    }
            case .loading:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
            case .success(let img):
                img
                    .resizable()
                    .scaledToFit()
            case .failure:
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.yellow)
            }
        }
    }
    
    private func getMapFromType(_ mapType: MapType) -> MapMap.ImageStatus {
        switch mapType {
        case .fullImage:
            return mapMap.image
        case .thumbnail:
            return mapMap.thumbnail
        case .original:
            guard let mapData = mapMap.mapMapRawEncodedImage,
                  let uiImage = UIImage(data: mapData)
            else { return .failure }
            return .success(
                Image(uiImage: uiImage)
            )
        }
    }
}
