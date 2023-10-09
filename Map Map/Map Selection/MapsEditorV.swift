//
//  MapEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/8/23.
//

import PhotosUI
import SwiftUI

struct MapsEditor: View {
    @StateObject var controller: MapsContainer
    @Environment(\.managedObjectContext) var moc // For adding and removing
    @Environment(\.dismiss) var dismiss
    @FetchRequest(sortDescriptors: []) var processedPhotos: FetchedResults<MapPhoto>
    @State var keyboardIsPresent: Bool = false
    
    init(rawPhotos: [PhotosPickerItem]) {
        self._controller = StateObject(wrappedValue: MapsContainer(rawPhotos: rawPhotos))
    }
    
    var body: some View {
        VStack {
            TabView {
                ForEach(processedPhotos, id: \.id) { photo in
                    if photo.isEditing { MapEditor(photo: photo) }
                }
            }
            .tabViewStyle(.page)
            }
            DoneButton(enabled: true, action: { dismiss() })
                .padding(.vertical, 20)
        }
        .background(.black)
    }
}
