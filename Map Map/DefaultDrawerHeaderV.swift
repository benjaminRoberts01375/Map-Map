//
//  DefaultDrawerHeaderV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/6/23.
//

import PhotosUI
import SwiftUI
import MobileCoreServices

/// Information and buttons to display in the header of the default bottom drawer.
struct DefaultDrawerHeaderV: View {
    /// Current Core Data managed object context.
    @Environment(\.managedObjectContext) private var moc
    /// Photos picked by the user from camera roll.
    @State private var rawPhotos: [PhotosPickerItem] = []
    /// Tracker for showing the photo picker.
    @State private var photosPickerPresented = false
    /// Tracker for showing the file picker
    @State private var filePickerPresented = false
    /// Tracker for showing the camera.
    @State private var cameraPresented = false
    
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
                Button {
                    filePickerPresented = true
                } label: {
                    Label("Files", systemImage: "folder.fill")
                }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .resizable()
                    .accessibilityLabel("Add Map Map Button")
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
        .fileImporter(isPresented: $filePickerPresented, allowedContentTypes: [.png, .jpeg]) { result in
            switch result {
            case .success(let url):
                // Get file permissions
                if !url.startAccessingSecurityScopedResource() { print("No access"); return }
                defer { url.stopAccessingSecurityScopedResource() }
                
                // Read file data
                let data: Data
                do { data = try Data(contentsOf: url) }
                catch { return }
                
                // Determine file type
                guard let fileType = UTType(filenameExtension: url.pathExtension)
                else { return }
                switch fileType {
                case .png, .jpeg:
                    if let image = UIImage(data: data) { _ = MapMap(rawPhoto: image, insertInto: moc) }
                default: return
                }
                
            case .failure(let error): return
            }
        }
        .sheet(isPresented: $cameraPresented, content: {
            CameraV()
        })
    }
}
