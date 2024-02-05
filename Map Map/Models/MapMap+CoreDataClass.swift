//
//  MapPhoto+CoreDataClass.swift
//  Map Map
//
//  Created by Ben Roberts on 10/8/23.
//
//

import CoreData
import MapKit
import SwiftUI

/// What the app is all about. Stores the GPS coordinates, scale, and more to place an image on the map.
@objc(MapMap)
public class MapMap: NSManagedObject {
    /// Formatted coordinates of the MapMap.
    public var coordinates: CLLocationCoordinate2D {
        get { CLLocationCoordinate2D(latitude: self.mapMapLatitude, longitude: self.mapMapLongitude) }
        set(coordinates) {
            self.mapMapLatitude = coordinates.latitude
            self.mapMapLongitude = coordinates.longitude
        }
    }
    
    /// Formatted Markers that are associated with this MapMap.
    var formattedMarkers: [Marker] {
        let markerSet = self.markers as? Set<Marker> ?? []
        return markerSet.sorted(by: { $0.latitude < $1.latitude })
    }
    
    /// Convenience getter and setter for native MapMap image size.
    var imageSize: CGSize? {
        if let imageCropped = self.imageCropped {
            return CGSize(width: CGFloat(imageCropped.imageWidth), height: CGFloat(imageCropped.imageHeight))
        }
        else if let imageDefault = self.imageDefault {
            return CGSize(width: CGFloat(imageDefault.imageWidth), height: CGFloat(imageDefault.imageHeight))
        }
        return nil
    }
    
    /// A simple getter for Map Images.
    var unwrappedImages: [MapImage] {
        let images = self.images as? Set<MapImage> ?? []
        return images.sorted(by: { $0.type < $1.type })
    }
    
    /// Active image.
    var activeImage: MapImage? {
        switch self.imageCropped?.image {
        case .success:
            return self.imageCropped
        case .empty:
            self.imageCropped?.loadImageFromCD()
            return imageCropped
        case .failure, .loading, .none:
            return self.imageDefault
        }
    }
    
    var imageCropped: MapImage? {
        get { self.unwrappedImages.first(where: { $0.imageType == .cropped }) }
        set(newValue) {
            guard let moc = self.managedObjectContext
            else { return }
            for unwrappedImage in unwrappedImages where unwrappedImage.imageType == .cropped {
                moc.delete(unwrappedImage)
            }
            guard let newMapImage = newValue
            else { return }
            self.addToImages(newMapImage)
        }
    }
    
    var imageDefault: MapImage? {
        self.unwrappedImages.first(where: { $0.imageType == .original })
    }
}

// MARK: Photo inits
extension MapMap {
    /// A convenience initializer for creating a MapMap from a UIImage.
    /// - Parameters:
    ///   - uiPhoto: Photo to base MapMap off of.
    ///   - moc: Managed Object Context to save into.
    public convenience init(uiPhoto: UIImage, moc: NSManagedObjectContext) {
        self.init(context: moc)
        self.isEditing = true
        self.addToImages(MapImage(image: uiPhoto, type: .original, moc: moc))
    }
}

// MARK: Perspective correction
extension MapMap {
    /// Check if the stored four corners are equal to multiple CGSizes.
    /// - Parameters:
    ///   - newCorners: Four cropped corners of an image.
    /// - Returns: Bool stating if the two are the same or not.
    func checkSameCorners(_ newCorners: FourCornersStorage) -> Bool {
        if let cropCorners = cropCorners {
            return cropCorners.topLeading == newCorners.topLeading.rounded() &&
            cropCorners.topTrailing == newCorners.topTrailing.rounded() &&
            cropCorners.bottomLeading == newCorners.bottomLeading.rounded() &&
            cropCorners.bottomTrailing == newCorners.bottomTrailing.rounded()
        }
        return false
    }
    
    /// Set the four corners.
    /// - Parameter newCorners: Updated corners.
    func setAndApplyCorners(corners newCorners: FourCornersStorage) -> UIImage? {
        guard let moc = self.managedObjectContext,
              let imageSize = self.imageDefault?.size
        else { return nil }
        if newCorners.topLeading != .zero || // If the crop corners are unique
            newCorners.topTrailing != CGSize(width: imageSize.width, height: .zero) ||
            newCorners.bottomLeading != CGSize(width: .zero, height: imageSize.height) ||
            newCorners.bottomTrailing != imageSize {
            self.cropCorners = FourCorners(
                topLeading: newCorners.topLeading.rounded(),
                topTrailing: newCorners.topTrailing.rounded(),
                bottomLeading: newCorners.bottomLeading.rounded(),
                bottomTrailing: newCorners.bottomTrailing.rounded(),
                insertInto: moc
            )
            return applyPerspectiveCorrectionWithCorners()
        }
        Task { // Crop corners were defaults
            self.cropCorners = nil
            if let imageCropped = self.imageCropped { moc.delete(imageCropped) }
        }
        return nil
    }
    
    /// Applies image correction based on the four corners of the MapMap.
    private func applyPerspectiveCorrectionWithCorners() -> UIImage? {
        guard let moc = self.managedObjectContext,
              let mapMapRawEncodedImage = self.imageDefault?.imageData, // Map map data
              let ciImage = CIImage(data: mapMapRawEncodedImage),       // Type ciImage
              let fourCorners = self.cropCorners,                       // Ensure fourCorners exists
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
        if let oldCroppedImage = self.imageCropped { moc.delete(oldCroppedImage) }
        
        return UIImage(cgImage: consume newCGImage)
    }
}
