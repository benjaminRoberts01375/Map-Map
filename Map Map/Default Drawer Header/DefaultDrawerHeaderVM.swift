//
//  DefaultDrawerHeaderVM.swift
//  Map Map
//
//  Created by Ben Roberts on 3/22/24.
//

import CoreData
import MobileCoreServices
import PDFKit
import PhotosUI
import SwiftUI

extension DefaultDrawerHeaderV {
    @Observable
    final class ViewModel {
        /// Photos picked by the user from camera roll.
        var rawPhotos: [PhotosPickerItem] = []
        /// Tracker for showing the photo picker.
        var photosPickerPresented = false
        /// Tracker for showing the file picker
        var filePickerPresented = false
        /// Tracker for showing the camera.
        var cameraPresented = false
        /// An error message to display when needed.
        var errorMessage: String = ""
        /// Trakcer for showing errors.
        var errorPresented = false
        /// GPS user location.
        var locationsHandler = LocationsHandler.shared
        /// Track if the store is currently being presented to the user.
        var storePresented = false
        
        /// Creates a MapMap from a URL if the resulting data is a `PNG` or `JPEG`.
        /// - Parameter url: URL to pull data from.
        func generateMapMapFromURL(_ url: URL, moc: NSManagedObjectContext) {
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
            case .pdf: importPDF(data, moc: moc)
            case .png, .jpeg:
                if let image = UIImage(data: data) { _ = MapMap(uiImage: image, moc: moc) }
            default:
                errorMessage = "We're not sure what kind of file this is. Import only PDFs, JPEGs, and PNGs."
                errorPresented = true
                return
            }
        }
        
        /// Create a MapMap from PDF data.
        /// - Parameter rawData: Data to create a MapMap from.
        private func importPDF(_ rawData: Data, moc: NSManagedObjectContext) {
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
            _ = MapMap(uiImage: image, moc: moc)
        }
        
    }
}
