//
//  MapMapImage+CoreDataClass.swift
//  
//
//  Created by Ben Roberts on 2/3/24.
//
//

import CoreData
import SwiftUI

@objc(MapMapImage)
public class MapMapImage: NSManagedObject {
    /// Resolution to use when generating a thumbnail
    static let thumbnailSize: CGSize = CGSize(width: 300, height: 300)
    
    /// Get the size of the image as a CGSize
    var imageSize: CGSize {
        get { CGSize(width: imageWidth, height: imageHeight) }
        set(newValue) {
            self.imageWidth = newValue.width
            self.imageHeight = newValue.height
        }
    }
    /// Get the orientation of the image as a formatted orientation.
    var unwrappedOrientation: Orientation { Orientation(rawValue: self.orientation) ?? .standard }

    /// Current setup status of the image.
    private(set) var imageStatus: ImageStatus = .empty { didSet { self.objectWillChange.send() } }
    /// Current setup status of the thumbnail.
    private(set) var thumbnailStatus: ImageStatus = .empty { didSet { self.objectWillChange.send() } }
    
    public enum ImageStatus: Equatable {
        case empty
        case loading
        case successful(UIImage)
        case failure
    }
    
    /// Load image from Core Data
    /// - Returns: Completed UIImage
    private func loadImage() async -> UIImage? {
        guard let imageData = imageData,
              let uiImage = UIImage(data: imageData)
        else { return nil }
        return uiImage
    }
    
    /// Load thumbnail from Core Data.
    /// - Returns: Completed UIImage.
    private func loadThumbnail() async -> UIImage? {
        guard let thumbnailData = thumbnailData,
              let uiImage = UIImage(data: thumbnailData)
        else { return nil }
        return uiImage
    }

    /// Asynchronously load the thumbnail and image from Core Data
    /// - Note: If a thumbnail is not available, one will be generated from the main image.
    public func loadFromCD() async {
        await MainActor.run {
            self.thumbnailStatus = .loading
            self.imageStatus = .loading
        }
        guard let uiImage = await loadImage()
        else {
            await MainActor.run {
                self.thumbnailStatus = .failure
                self.imageStatus = .failure
            }
            return
        }
        await MainActor.run { imageStatus = .successful(uiImage) }
        if let thumbnailImage = await loadThumbnail() {
            await MainActor.run { thumbnailStatus = .successful(thumbnailImage) }
            return // All is good in the world
        }
        if let thumbnail = await generateThumbnail(from: uiImage) { // WHERE'D THE THUMBNAIL GO?!
            await MainActor.run { thumbnailStatus = .successful(thumbnail) }
        }
        else { await MainActor.run { thumbnailStatus = .failure } } // WHY IS IT GONE?!??!
    }
    
    /// Generate a thumbnail from the base image.
    private func generateThumbnail(from uiImage: UIImage) async -> UIImage? {
        return await uiImage.byPreparingThumbnail(ofSize: MapMapImage.thumbnailSize)
    }
}

public extension MapMapImage {
    /// Create a MapMap Image from a UIImage
    /// - Parameters:
    ///   - uiImage: UIImage to create from.
    ///   - baseImage: If this MapMapImage is based off another MapMap image, a path can be created back.
    ///   - moc: Managed Object Context to insert into
    convenience init(
        uiImage: UIImage,
        orientation: Orientation = .standard,
        cropCorners: CropCornersStorage? = nil,
        moc: NSManagedObjectContext
    ) {
        self.init(context: moc)
        self.thumbnailStatus = .loading
        self.imageStatus = .successful(uiImage)
        self.orientation = orientation.rawValue
        self.imageWidth = uiImage.size.width
        self.imageHeight = uiImage.size.height
        self.imageData = uiImage.jpegData(compressionQuality: 0.1)
        if let cropCorners = cropCorners {
            self.cropCorners = MapMapImageCropCorners(
                topLeading: cropCorners.topLeading,
                topTrailing: cropCorners.topTrailing,
                bottomLeading: cropCorners.bottomLeading,
                bottomTrailing: cropCorners.bottomTrailing,
                insertInto: moc
            )
        }
        Task {
            if let thumbnail = await generateThumbnail(from: uiImage) {
                await MainActor.run {
                    self.thumbnailStatus = .successful(thumbnail)
                    self.thumbnailData = thumbnail.jpegData(compressionQuality: 0.1)
                }
            }
            else { await MainActor.run { self.thumbnailStatus = .failure } }
        }
    }
}

public extension MapMapImage {
    /// Check if the stored four corners are equal to multiple CGSizes.
    /// - Parameters:
    ///   - newCorners: Four cropped corners of an image.
    /// - Returns: Bool stating if the two are the same or not.
    func checkSameCorners(_ newCorners: CropCornersStorage) -> Bool {
        if let cropCorners = self.imageContainer?.activeContainerImage?.cropCorners {
            return cropCorners.topLeading == newCorners.topLeading.rounded() &&
            cropCorners.topTrailing == newCorners.topTrailing.rounded() &&
            cropCorners.bottomLeading == newCorners.bottomLeading.rounded() &&
            cropCorners.bottomTrailing == newCorners.bottomTrailing.rounded()
        }
        return false
    }
    
    /// Set the four corners.
    /// - Parameter newCorners: Updated corners.
    func setAndApplyCorners(corners newCorners: CropCornersStorage) -> UIImage? {
        guard let moc = self.managedObjectContext
        else { return nil }
        let roundedCorners = newCorners.round()
        if roundedCorners != imageSize {
            return applyPerspectiveCorrectionFromCorners(fourCorners: roundedCorners)
        }
        // Crop corners were defaults
        if self.imageContainer?.unwrappedImages.count ?? 1 > 1, // More than 1 image in this container
            let activeImage = self.imageContainer?.mapMap?.activeImage {
            moc.delete(activeImage)
        }
        return nil
    }
    
    /// Applies image correction based on the four corners of the MapMap.
    /// - Parameter fourCorners: Corners to use when cropping this image.
    /// - Returns: Cropped image
    private func applyPerspectiveCorrectionFromCorners(fourCorners: CropCornersStorage) -> UIImage? {
        guard let mapMapRawEncodedImage = self.imageData, // Map map data
              let ciImage = CIImage(data: mapMapRawEncodedImage),       // Type ciImage
              let filter = CIFilter(name: "CIPerspectiveCorrection")    // Filter to use
        else { return nil }
        let context = CIContext()
        
        func cartesianVecForPoint(_ point: CGSize) -> CIVector {
            return CIVector(x: point.width, y: ciImage.extent.height - point.height)
        }
        
        filter.setValue(cartesianVecForPoint(fourCorners.topLeading), forKey: "inputTopLeft")
        filter.setValue(cartesianVecForPoint(fourCorners.topTrailing), forKey: "inputTopRight")
        filter.setValue(cartesianVecForPoint(fourCorners.bottomLeading), forKey: "inputBottomLeft")
        filter.setValue(cartesianVecForPoint(fourCorners.bottomTrailing), forKey: "inputBottomRight")
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let newCIImage = filter.outputImage,
              let newCGImage = context.createCGImage(newCIImage, from: newCIImage.extent)
        else { return nil }
        
        return UIImage(cgImage: consume newCGImage)
    }
 }
