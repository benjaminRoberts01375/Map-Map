//
//  MapListV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/8/23.
//

import PhotosUI
import SwiftUI

struct MapMapsViewer: View {
    @State var rawPhotos: [PhotosPickerItem] = []
    @FetchRequest(sortDescriptors: []) var mapMaps: FetchedResults<MapMap>
    @Environment(\.managedObjectContext) var moc // For adding and removing
    let listMode: ListMode
    
    var body: some View {
        VStack {
            MapMapList(listMode: listMode)
            PhotosPicker("Select", selection: $rawPhotos, maxSelectionCount: 30, matching: .images)
                .onChange(of: rawPhotos) { _, updatedRawPhotos in
                    if updatedRawPhotos.isEmpty { return }
                    for rawPhoto in updatedRawPhotos {
                        _ = MapMap(rawPhoto: rawPhoto, insertInto: moc)
                    }
                    rawPhotos = []
                }
        }
    }
}

#Preview {
    MapMapsViewer(listMode: .full)
}

#Preview {
    MapMapsViewer(listMode: .compact)
}
