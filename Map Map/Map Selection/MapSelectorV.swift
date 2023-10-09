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
    
    var body: some View {
        VStack {
            MapList()
            PhotosPicker("Select", selection: $rawPhotos, maxSelectionCount: 30, matching: .images)
                .onChange(of: rawPhotos) { update in
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        mapProcessing = true
                    }
                }
                .fullScreenCover(isPresented: $mapProcessing, content: {
                    MapsEditor(rawPhotos: rawPhotos)
                })
        }
    }
}

#Preview {
    MapSelector()
}
