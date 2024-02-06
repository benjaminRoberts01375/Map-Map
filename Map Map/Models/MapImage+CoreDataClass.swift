//
//  MapImage+CoreDataClass.swift
//  
//
//  Created by Ben Roberts on 2/3/24.
//
//

import CoreData
import SwiftUI

@objc(MapImage)
public class MapImage: NSManagedObject {
    /// Current status type of this MapMap.
    public enum ImageStatus {
        case empty
        case loading
        case success(Image)
        case failure
    }
    /// Resolution of the thumbnail.
    static let thumbnailSize: CGSize = CGSize(width: 300, height: 300)
    /// This image
    @Published public var image: ImageStatus = .empty
    /// Thumbnail of this image.
    @Published public var thumbnail: ImageStatus = .empty
    /// Simple getter and private setter for this image.
    private(set) var size: CGSize {
        get { CGSize(width: CGFloat(self.imageWidth), height: CGFloat(self.imageHeight)) }
        set(newValue) {
            self.imageWidth = Int16(newValue.width)
            self.imageHeight = Int16(newValue.height)
        }
    }
    
    /// Formatted image type.
    public var imageType: ImageType {
        get { ImageType(rawValue: self.type) ?? .original }
        set(newValue) { self.type = newValue.rawValue }
    }
    
    /// Generate a thumbnail from this image.
    private func generateThumbnail() async {
        guard let imageData = imageData,
              let uiImage = UIImage(data: imageData)
        else { return }
        await generateThumbnail(image: uiImage)
    }
    
    /// Generate a thumbnail from the provided image.
    /// - Parameter image: Base image.
    func generateThumbnail(image: UIImage) async {
        guard let thumbnail = await image.byPreparingThumbnail(ofSize: MapImage.thumbnailSize)
        else {
            DispatchQueue.main.async { self.thumbnail = .failure }
            return
        }
        await MainActor.run { [thumbnail] in
            self.thumbnail = .success(Image(uiImage: thumbnail))
        }
        self.thumbnailData = thumbnail.jpegData(compressionQuality: 0.1)
    }
    
    /// Load the image and thumbnail from Core Data.
    func loadImageFromCD() {
        self.image = .loading
        guard let imageData = imageData,
              let uiImage = UIImage(data: imageData)
        else {
            image = .failure
            return
        }
        self.image = .success(Image(uiImage: uiImage))
        
        guard let thumbnailData = thumbnailData,
              let uiThumbnail = UIImage(data: thumbnailData)
        else {
            Task { await generateThumbnail() }
            return
        }
        self.thumbnail = .success(Image(uiImage: uiThumbnail))
    }
    
    /// Type of image.
    public enum ImageType: Int16 {
        case original = 0
        case cropped = 1
    }
}

extension MapImage {
    /// Creates a Map Image from a UIImage
    /// - Parameters:
    ///   - image: Image to base Map Image on.
    ///   - type: Type of image being created.
    ///   - moc: Managed Object Context to save into.
    public convenience init(image: UIImage, type: ImageType, moc: NSManagedObjectContext) {
        self.init(context: moc)
        self.imageType = type
        self.image = .success(Image(uiImage: image))
        self.size = image.size
        Task { _ = await generateThumbnail(image: image) }
        self.imageData = image.jpegData(compressionQuality: 0.1)
    }
}
