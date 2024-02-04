//
//  MapPhoto+CoreDataClass.swift
//  Map Map
//
//  Created by Ben Roberts on 10/8/23.
//
//

import CoreData
import MapKit
import PhotosUI
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
        if let imageDefault = self.imageDefault {
            return CGSize(width: CGFloat(imageDefault.imageWidth), height: CGFloat(imageDefault.imageHeight))
        }
        else if let imageCropped = self.imageCropped {
            return CGSize(width: CGFloat(imageCropped.imageWidth), height: CGFloat(imageCropped.imageHeight))
        }
        return nil
    }
    
    var image: MapImage? {
        if self.imageCropped != nil { return self.imageCropped }
        return self.imageDefault
    }
    
    /// Check if the stored four corners are equal to multiple CGSizes.
    /// - Parameters:
    ///   - topLeading: Top Leading point of four corners.
    ///   - topTrailing: Top trailing point of four corners.
    ///   - bottomLeading: Bottom leading point of four corners.
    ///   - bottomTrailing: Bottom trailing point of four corners
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
    func setAndApplyCorners(corners newCorners: FourCornersStorage) -> UIImage? {
        guard let moc = self.managedObjectContext,
              let imageSize = self.imageSize
        else { return nil }
        if newCorners.topLeading != .zero || // If the crop corners are unique
            newCorners.topTrailing != CGSize(width: imageSize.width, height: .zero) ||
            newCorners.bottomLeading != CGSize(width: .zero, height: imageSize.height) ||
            newCorners.bottomTrailing != CGSize(width: imageSize.width, height: imageSize.height) {
            let cropCorners = FourCorners(
                topLeading: newCorners.topLeading.rounded(),
                topTrailing: newCorners.topTrailing.rounded(),
                bottomLeading: newCorners.bottomLeading.rounded(),
                bottomTrailing: newCorners.bottomTrailing.rounded(),
                insertInto: moc
            )
            self.cropCorners = cropCorners
            return applyPerspectiveCorrectionWithCorners()
        }
        // Crop corners were defaults
        self.cropCorners = nil
        if let imageCropped = self.imageCropped { moc.delete(imageCropped) }
        return nil
    }
}

// MARK: Photo inits
extension MapMap {
    public convenience init(uiPhoto: UIImage, moc: NSManagedObjectContext) {
        self.init(context: moc)
        self.isEditing = true
        let outputImage = Image(uiImage: uiPhoto)
        self.imageDefault = MapImage(image: uiPhoto, moc: moc)
    }
}

// MARK: Perspective correction
extension MapMap {
    /// Applies image correction based on the four corners of the MapMap.
    private func applyPerspectiveCorrectionWithCorners() -> UIImage? {
        guard let mapMapRawEncodedImage = self.mapMapRawEncodedImage,   // Map map data
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
        
        let newUIImage = UIImage(cgImage: consume newCGImage)
        let outputImage = Image(uiImage: newUIImage)
        let result: ImageStatus = .success(outputImage)
        DispatchQueue.main.async { self.image = result }
        return newUIImage
    }
    
    /// Save the provided image to the Map Map.
    /// - Parameter image: Image to save.
    public func saveCroppedImage(image: UIImage) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .savingToastNotification,
                object: nil,
                userInfo: ["savingVal":true, "name":self.mapMapName ?? "Unknown map"]
            )
        }
        let result = image.pngData()
        DispatchQueue.main.async {
            self.mapMapPerspectiveFixedEncodedImage = result
            NotificationCenter.default.post(name: .savingToastNotification, object: nil, userInfo: ["savingVal":false])
        }
    }
}
