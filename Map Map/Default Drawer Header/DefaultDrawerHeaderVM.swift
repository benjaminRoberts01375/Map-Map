//
//  DefaultDrawerHeaderVM.swift
//  Map Map
//
//  Created by Ben Roberts on 3/22/24.
//

import CoreData
import PDFKit
import PhotosUI
import StoreKit
import SwiftUI

extension DefaultDrawerHeaderV {
    /// View model for the DefaultDrawerHeaderV.
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
        /// Tracker for showing errors.
        var alertManager = AlertManager()
        /// GPS user location.
        var locationsHandler = LocationsHandler.shared
        /// Track if the store is currently being presented to the user.
        var storePresented = false
        /// Track if the user has gotten the explorer package
        var boughtExplorer = false
        
        init() {
//#if DEBUG
//            self.boughtExplorer = true
//#elseif DEBUG
            Task {
                let bought = await checkIfExplorerPurchased()
                await MainActor.run { self.boughtExplorer = bought }
            }
//#endif
        }
        
        /// Creates a MapMap from a URL if the resulting data is a `PNG` or `JPEG`.
        /// - Parameter url: URL to pull data from.
        func generateMapMapFromURL(_ url: URL, moc: NSManagedObjectContext) {
            // Get file permissions
            if !url.startAccessingSecurityScopedResource() {
                alertManager.noFilePermission = true
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            
            // Read file data
            let data: Data
            do { data = try Data(contentsOf: url) }
            catch {
                alertManager.fileNotReadable = true
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
                alertManager.unknownImageType = true
                return
            }
        }
        
        /// Create a MapMap from PDF data.
        /// - Parameter rawData: Data to create a MapMap from.
        private func importPDF(_ rawData: Data, moc: NSManagedObjectContext) {
            guard let document = PDFDocument(data: rawData),
                  let firstPage = document.page(at: 0)
            else {
                alertManager.unableToReadPDF = true
                return
            }
            
            let bounds = firstPage.bounds(for: .cropBox)
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            let imageData = renderer.pngData { context in // A workaround to renderer.image because of weird underlying data issues
                // Flip the coordinate system
                context.cgContext.translateBy(x: 0, y: bounds.size.height)
                context.cgContext.scaleBy(x: 1.0, y: -1.0)
                UIColor.white.set() // Set background
                context.fill(bounds)
                
                // Draw the PDF page using PDFPage's draw method
                firstPage.draw(with: .cropBox, to: context.cgContext)
            }
            guard let imageAgain = UIImage(data: imageData)
            else { return }
            _ = MapMap(uiImage: imageAgain, moc: moc)
        }
        
        /// Check the latest latest transaction for the explorer package. If one exists, there was a purchase.
        /// - Returns: Bool if there was a purchase.
        func checkIfExplorerPurchased() async -> Bool {
            let products = try? await Product.products(for: [Product.kExplorer])
            guard let product = products?.first else { return false }
            return await product.latestTransaction != nil // Can use a switch on this to get receipt
        }
    }
}
