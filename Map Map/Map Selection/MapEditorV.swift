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
    @FetchRequest(sortDescriptors: []) var processedPhotos: FetchedResults<MapPhoto>
    
    init(rawPhotos: [PhotosPickerItem]) {
        self._controller = StateObject(wrappedValue: MapContainer(rawPhotos: rawPhotos))
    }
    
    var body: some View {
        VStack {
            TabView {
                ForEach(processedPhotos, id: \.id) { photo in
                    if photo.mapName == nil {
                        switch photo.image {
                        case .loading(let loading):
                            AnyView(loading)
                        case .failure(let failure):
                            AnyView(failure)
                        case .success(let image):
                            AnyView(image)
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
