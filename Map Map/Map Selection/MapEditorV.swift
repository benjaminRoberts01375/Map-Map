//
//  MapEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/8/23.
//

import PhotosUI
import SwiftUI

struct MapEditor: View {
    @StateObject var controller: MapContainer
    @Environment(\.managedObjectContext) var moc // For adding and removing
    
    init(rawPhotos: [PhotosPickerItem]) {
        self._controller = StateObject(wrappedValue: MapContainer(rawPhotos: rawPhotos))
    }
    
    var body: some View {
        VStack {
            Text("Editor")
            TabView {
                ForEach(controller.processedPhotos, id: \.id) { photo in
                    switch photo.image {
                    case .loading:
                        ProgressView()
                    case .failure:
                        VStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(.yellow)
                        }
                    case .success(let image):
                        VStack {
                            image
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }
            }
            .tabViewStyle(.page)
            .onAppear {
                controller.convertPhotosPickerItem(moc: moc)
            }
        }
    }
}
