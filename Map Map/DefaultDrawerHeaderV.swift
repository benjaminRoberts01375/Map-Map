//
//  DefaultDrawerHeaderV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/6/23.
//

import PhotosUI
import SwiftUI

struct DefaultDrawerHeaderV: View {
    @Environment(\.managedObjectContext) var moc
    @State var rawPhotos: [PhotosPickerItem] = []
    @State var photosPickerPresented = false
    @State var cameraPresented = false
    
    var body: some View {
        HStack {
            Text("Your Map Maps")
                .font(.title)
                .fontWeight(.bold)
                .padding([.leading])
            
            Menu {
                Button(action: {
                    cameraPresented = true
                }, label: {
                    Label("Camera", systemImage: "camera.fill")
                })
                Button {
                    photosPickerPresented = true
                } label: {
                    Label("Photo Library", systemImage: "photo.on.rectangle.angled")
                        .symbolRenderingMode(.hierarchical)
                }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .resizable()
                    .frame(width: 22, height: 22)
            }
            
            Spacer()
        }
        .onChange(of: rawPhotos) { _, updatedRawPhotos in
            if updatedRawPhotos.isEmpty { return }
            for rawPhoto in updatedRawPhotos { _ = MapMap(rawPhoto: rawPhoto, insertInto: moc) }
            rawPhotos = []
        }
        .photosPicker(isPresented: $photosPickerPresented, selection: $rawPhotos, maxSelectionCount: 1, matching: .images)
        .sheet(isPresented: $cameraPresented, content: {
            CameraPreviewV()
        })
    }
}
