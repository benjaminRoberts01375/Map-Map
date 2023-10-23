//
//  MapListV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/8/23.
//

import PhotosUI
import SwiftUI

struct MapsViewer: View {
    @State var rawPhotos: [PhotosPickerItem] = []
    @FetchRequest(sortDescriptors: []) var processedPhotos: FetchedResults<MapPhoto>
    @Environment(\.managedObjectContext) var moc // For adding and removing
    let listMode: ListMode
    
    var body: some View {
        VStack {
            MapList(listMode: listMode)
            PhotosPicker("Select", selection: $rawPhotos, maxSelectionCount: 30, matching: .images)
                .onChange(of: rawPhotos) { _, updatedRawPhotos in
                    if updatedRawPhotos.isEmpty { return }
                    for rawPhoto in updatedRawPhotos {
                        _ = MapPhoto(rawPhoto: rawPhoto, insertInto: moc)
                    }
                    rawPhotos = []
                }
        }
    }
}

#Preview {
    MapsViewer(listMode: .full)
}

#Preview {
    MapsViewer(listMode: .compact)
}
