//
//  DefaultDrawerHeaderV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/6/23.
//

import MobileCoreServices
import PDFKit
import PhotosUI
import SwiftUI

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
    /// An error message to display when needed.
    @State private var errorMessage: String = ""
    /// Trakcer for showing errors.
    @State private var errorPresented = false
    
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
        .fileImporter(isPresented: $filePickerPresented, allowedContentTypes: [.png, .jpeg, .pdf]) { result in
            switch result {
            case .success(let url): generateMapMapFromURL(url)
            case .failure: return
            }
        }
        .sheet(isPresented: $cameraPresented, content: {
            CameraV()
        })
    }
    
    /// Creates a MapMap from a URL if the resulting data is a `PNG` or `JPEG`.
    /// - Parameter url: URL to pull data from.
    private func generateMapMapFromURL(_ url: URL) {
        // Get file permissions
        if !url.startAccessingSecurityScopedResource() {
            errorMessage = "We're not able to get permission to open your file."
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        // Read file data
        let data: Data
        do { data = try Data(contentsOf: url) }
        catch {
            errorMessage = "We're not able to read your file."
            errorPresented = true
            return
        }
        // Determine file type
        guard let fileType = UTType(filenameExtension: url.pathExtension)
        else { return }
        switch fileType {
        case .pdf: importPDF(data)
        case .png, .jpeg:
            if let image = UIImage(data: data) { _ = MapMap(rawPhoto: image, insertInto: moc) }
        default:
            errorMessage = "We're not sure what kind of file this is. Import only PDFs, JPEGs, and PNGs."
            errorPresented = true
            return
        }
    }
    
    /// Create a MapMap from PDF data.
    /// - Parameter rawData: Data to create a MapMap from.
    private func importPDF(_ rawData: Data) {
        guard let document = PDFDocument(data: rawData),
              let firstPage = document.page(at: 0) 
        else {
            errorMessage = "We're not able to read your PDF."
            errorPresented = true
            return
        }

        let bounds = firstPage.bounds(for: .cropBox)
        let renderer = UIGraphicsImageRenderer(bounds: bounds)

        let image = renderer.image { context in
            // Flip the coordinate system
            context.cgContext.translateBy(x: 0, y: bounds.size.height)
            context.cgContext.scaleBy(x: 1.0, y: -1.0)
            UIColor.white.set() // Set background
            context.fill(bounds)

            // Draw the PDF page using PDFPage's draw method
            firstPage.draw(with: .cropBox, to: context.cgContext)
        }
        _ = MapMap(rawPhoto: image, insertInto: moc)
    }
}
