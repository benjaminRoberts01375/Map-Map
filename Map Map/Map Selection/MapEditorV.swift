//
//  MapEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/8/23.
//

import PhotosUI
import SwiftUI

struct MapEditor: View {
    var rawPhotos: [PhotosPickerItem]
    var processedPhotos: [Image]?
    
    var body: some View {
        TabView {
            ForEach(rawPhotos, id: \.hashValue) { rawPhoto in
                ImageSwitch(rawImage: rawPhoto)
                    .scaledToFit()
//                    .frame(width: 200)
            }
        }
        .tabViewStyle(.page)
    }
}

struct ImageSwitch: View {
    @State var imageState: ImageState = .loading
    let rawImage: PhotosPickerItem?
    
    enum ImageState {
        case loading
        case failed
        case success(Image)
    }
    
    private func loadImage(_ rawPhoto: PhotosPickerItem?) {
        Task {
            if let data = try? await rawPhoto?.loadTransferable(type: Image.self) {
                imageState = .success(data)
                return
                
            }
        }
    }
    
    var body: some View {
        VStack {
            switch imageState {
            case .loading:
                ProgressView()
            case .failed:
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.yellow)
            case .success(let image):
                image
                    .resizable()
            }
        }
        .onAppear {
            loadImage(rawImage)
        }
    }
}
