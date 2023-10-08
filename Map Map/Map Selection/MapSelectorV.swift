//
//  MapListV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/8/23.
//

import PhotosUI
import SwiftUI

struct MapSelector: View {
    @State var newPhoto: [PhotosPickerItem] = []
    @State var mapProcessing = false
    
    var body: some View {
        VStack {
            MapList()
            PhotosPicker("Select", selection: $newPhoto, maxSelectionCount: 1, matching: .images)
                .onChange(of: newPhoto) { update in
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        mapProcessing = true
                    }
                }
                .fullScreenCover(isPresented: $mapProcessing, content: {
                    Text("Processing!")
                })
        }
    }
}

#Preview {
    MapSelector()
}
