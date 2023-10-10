//
//  MapListV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/8/23.
//

import PhotosUI
import SwiftUI

struct MapSelector: View {
    @State var rawPhotos: [PhotosPickerItem] = []
    @State var mapProcessing = false
    @FetchRequest(sortDescriptors: []) var processedPhotos: FetchedResults<MapPhoto>
    @Environment(\.managedObjectContext) var moc // For adding and removing
    
    var body: some View {
        VStack {
            MapList()
            PhotosPicker("Select", selection: $rawPhotos, maxSelectionCount: 30, matching: .images)
                .onChange(of: rawPhotos) { update in
                    if rawPhotos.isEmpty { return }
                    for rawPhoto in rawPhotos {
                        _ = MapPhoto(rawPhoto: rawPhoto, insertInto: moc)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        mapProcessing = true
                    }
                    rawPhotos = []
                }
                .fullScreenCover(
                    isPresented: $mapProcessing,
                    content: { MapsEditor(rawPhotos: rawPhotos) })
        }
    }
}

#Preview {
    MapSelector()
}
