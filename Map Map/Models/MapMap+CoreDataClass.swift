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

@objc(MapMap)
public class MapMap: NSManagedObject {
    @Published public var image: ImageStatus = .empty 
    { didSet { self.objectWillChange.send() } }
    @Published public var thumbnail: ImageStatus = .empty
    static let thumbnailSize: CGSize = CGSize(width: 300, height: 300)
    public var coordinates: CLLocationCoordinate2D {
        get { CLLocationCoordinate2D(latitude: self.mapMapLatitude , longitude: self.mapMapLongitude) }
        set(coordinates) {
            self.mapMapLatitude = coordinates.latitude
            self.mapMapLongitude = coordinates.longitude
        }
    }
    
    var formattedMarkers: [Marker] {
        let markerSet = self.markers as? Set<Marker> ?? []
        return markerSet.sorted(by: { $0.latitude < $1.latitude })
    }
    
    public enum ImageStatus {
        case empty
        case loading
        case success(Image)
        case failure
    }
    
    public func loadImageFromCD() {
        let workingImage: Data? = self.cropCorners == nil ? self.mapMapRawEncodedImage : self.mapMapPerspectiveFixedEncodedImage
        if let mapData = workingImage { // Available in Core Data
            if let uiImage = UIImage(data: mapData) {
                let outputImage = Image(uiImage: uiImage)
                DispatchQueue.main.async { self.image = .success(outputImage) }
                if self.mapMapEncodedThumbnail == nil { generateThumbnailFromUIImage(uiImage) }
                else { loadThumbnailFromCD() }
                return
            }
        }
        else {
            DispatchQueue.main.async {
                self.image = .failure
                self.thumbnail = .failure
            }
        }
    }
    
    private func generateThumbnailFromUIImage(_ uiImage: UIImage) {
        Task {
            if let generatedThumbnail = await uiImage.byPreparingThumbnail(ofSize: MapMap.thumbnailSize) {
                let outputImage = Image(uiImage: generatedThumbnail)
                DispatchQueue.main.async { self.thumbnail = .success(outputImage) }
                self.mapMapEncodedThumbnail = generatedThumbnail.jpegData(compressionQuality: 0.1)
            }
            else {
                DispatchQueue.main.async { self.thumbnail = .failure }
            }
        }
    }
    
    private func loadThumbnailFromCD() {
        if let mapThumbnail = self.mapMapEncodedThumbnail {
            if let uiImage = UIImage(data: mapThumbnail) {
                let outputImage = Image(uiImage: uiImage)
                DispatchQueue.main.async { self.thumbnail = .success(outputImage) }
                return
            }
        }
        DispatchQueue.main.async { self.thumbnail = .failure }
    }
    
    public func setAndApplyCorners(topLeading: CGSize, topTrailing: CGSize, bottomLeading: CGSize, bottomTrailing: CGSize) {
        if let cropCorners = cropCorners, // If crop corners exist, and they're equal to what's already defined...
           cropCorners.topLeading == topLeading.rounded() &&
            cropCorners.topTrailing == topTrailing.rounded() &&
            cropCorners.bottomLeading == bottomLeading.rounded() &&
            cropCorners.bottomTrailing == bottomTrailing.rounded() {
            return
        }
        
        guard let context = self.managedObjectContext else { return }
        let cropCorners = FourCorners(
            topLeading: topLeading.rounded(),
            topTrailing: topTrailing.rounded(),
            bottomLeading: bottomLeading.rounded(),
            bottomTrailing: bottomTrailing.rounded(),
            insertInto: context
        )
        if cropCorners.topLeading != .zero || // If the crop corners are unique
            cropCorners.topTrailing != CGSize(width: imageWidth, height: .zero) ||
            cropCorners.bottomLeading != CGSize(width: .zero, height: imageHeight) ||
            cropCorners.bottomTrailing != CGSize(width: imageWidth, height: imageHeight) {
            self.cropCorners = cropCorners
            applyPerspectiveCorrectionWithCorners()
            return
        }
        // Crop corners were not unique
        self.cropCorners = nil
        self.mapMapPerspectiveFixedEncodedImage = nil
        loadImageFromCD()
    }
}

// MARK: Photo inits
extension MapMap {
    convenience public init(rawPhoto: PhotosPickerItem?, insertInto context: NSManagedObjectContext) {
        self.init(context: context)
        thumbnail = .loading
        image = .loading
        self.mapMapName = "Untitled map"
        Task {
            if let mapData = try? await rawPhoto?.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: mapData)?.fixOrientation() {
                    self.mapMapRawEncodedImage = uiImage.jpegData(compressionQuality: 0.1)
                    self.imageWidth = uiImage.size.width.rounded()
                    self.imageHeight = uiImage.size.height.rounded()
                    let outputImage = Image(uiImage: uiImage)
                    DispatchQueue.main.async { self.image = .success(outputImage) }
                    generateThumbnailFromUIImage(uiImage)
                    return
                }
            }
            DispatchQueue.main.async {
                self.thumbnail = .failure
                self.image = .failure
            }
        }
    }
    
    convenience public init(rawPhoto: UIImage, insertInto context: NSManagedObjectContext) {
        self.init(context: context)
        image = .success(Image(uiImage: rawPhoto))
        Task {
            thumbnail = .loading
            self.mapMapName = "Untitled map"
            
            guard let jpegData = rawPhoto.jpegData(compressionQuality: 0.1),
                  let uiImage = UIImage(data: jpegData)
            else {
                image = .failure
                return
            }
            let outputImage = Image(uiImage: uiImage)
            DispatchQueue.main.async { self.image = .success(outputImage) }
            self.mapMapRawEncodedImage = jpegData
            self.imageWidth = rawPhoto.size.width
            self.imageHeight = rawPhoto.size.height
            generateThumbnailFromUIImage(uiImage)
        }
    }
}

// MARK: Perspective correction
extension MapMap {
    private func applyPerspectiveCorrectionWithCorners() {
        guard let mapMapRawEncodedImage = self.mapMapRawEncodedImage,   // Map map data
              let ciImage = CIImage(data: mapMapRawEncodedImage),       // Type ciImage
              let fourCorners = self.cropCorners,                       // Ensure fourCorners exists
              let filter = CIFilter(name: "CIPerspectiveCorrection")    // Filter to use
        else { return }
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
        else { return }
        
        let newUIImage = UIImage(cgImage: consume newCGImage)
        let result: ImageStatus = .success(Image(uiImage: newUIImage))
        DispatchQueue.main.async {
            self.image = result
            self.objectWillChange.send()
        }
        
        Task {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .savingToastNotification, object: nil, userInfo: ["savingVal":true, "name":self.mapMapName ?? "Unknown map"])
            }
            let result = newUIImage.pngData()
            DispatchQueue.main.async {
                self.mapMapPerspectiveFixedEncodedImage = result
                NotificationCenter.default.post(name: .savingToastNotification, object: nil, userInfo: ["savingVal":false])
            }
        }
    }
}
