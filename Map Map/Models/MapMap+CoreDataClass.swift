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
    @Published private var image: ImageStatus = .empty
    @Published private var thumbnail: ImageStatus = .empty
    private let thumbnailSize: CGSize = CGSize(width: 300, height: 300)
    public var coordinates: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: self.mapMapLatitude , longitude: self.mapMapLongitude)
        }
        set(coordinates) {
            self.mapMapLatitude = coordinates.latitude
            self.mapMapLongitude = coordinates.longitude
        }
    }
    
    public enum ImageStatus {
        case empty
        case loading
        case success(any View)
        case failure
    }
    
    public enum MapType {
        case thumbnail
        case fullImage
        case original
    }
    
    public func getMap(_ mapType: MapType) -> any View {
        switch getMapFromType(mapType) {
        case .empty:
            Task { loadImageFromCD() }
            return ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
        case .loading:
            return ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
        case .success(let img):
            return img
        case .failure:
            return Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.yellow)
        }
    }
    
    private func getMapFromType(_ mapType: MapType) -> ImageStatus {
        switch mapType {
        case .fullImage:
            return image
        case .thumbnail:
            return thumbnail
        case .original:
            guard let mapData = self.mapMapRawEncodedImage,
                  let uiImage = UIImage(data: mapData)
            else { return .failure }
            return .success(
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            )
        }
    }
    
    private func loadImageFromCD() {
        self.image = .loading
        self.thumbnail = .loading
        let workingImage: Data? = self.cropCorners == nil ? self.mapMapRawEncodedImage : self.mapMapPerspectiveFixedEncodedImage
        if let mapData = workingImage { // Available in Core Data
            if let uiImage = UIImage(data: mapData) {
                image = .success(
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                )
                if self.imageWidth == .zero { self.imageWidth = uiImage.size.width }
                if self.imageHeight == .zero { self.imageHeight = uiImage.size.height }
                if self.mapMapEncodedThumbnail == nil { generateThumbnailFromUIImage(uiImage) }
                else { loadThumbnailFromCD() }
                return
            }
        }
        else {
            image = .failure
            thumbnail = .failure
        }
    }
    
    private func generateThumbnailFromUIImage(_ uiImage: UIImage) {
        Task {
            if let generatedThumbnail = await uiImage.byPreparingThumbnail(ofSize: thumbnailSize) {
                thumbnail = .success(Image(uiImage: generatedThumbnail).resizable().scaledToFit())
                self.mapMapEncodedThumbnail = generatedThumbnail.jpegData(compressionQuality: 0.8)
            }
            else {
                thumbnail = .failure
            }
        }
    }
    
    private func loadThumbnailFromCD() {
        if let mapThumbnail = self.mapMapEncodedThumbnail {
            if let uiImage = UIImage(data: mapThumbnail) {
                thumbnail = .success(Image(uiImage: uiImage).resizable().scaledToFit())
                return
            }
        }
        thumbnail = .failure
    }
    
    public func setCorners(topLeading: CGSize, topTrailing: CGSize, bottomLeading: CGSize, bottomTrailing: CGSize) {
        guard let context = self.managedObjectContext else { return }
        self.cropCorners = FourCorners(
            topLeading: topLeading,
            topTrailing: topTrailing,
            bottomLeading: bottomLeading,
            bottomTrailing: bottomTrailing,
            insertInto: context
        )
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
                self.mapMapRawEncodedImage = mapData
                if let uiImage = UIImage(data: mapData) {
                    self.imageWidth = uiImage.size.width
                    self.imageHeight = uiImage.size.height
                    image = .success(Image(uiImage: uiImage).resizable().scaledToFit())
                    generateThumbnailFromUIImage(uiImage)
                    return
                }
            }
            thumbnail = .failure
            image = .failure
        }
    }
    
    convenience public init(rawPhoto: UIImage, insertInto context: NSManagedObjectContext) {
        self.init(context: context)
        image = .success(Image(uiImage: rawPhoto).resizable().scaledToFit())
        Task {
            thumbnail = .loading
            self.mapMapName = "Untitled map"
            
            guard let jpegData = rawPhoto.jpegData(compressionQuality: 90),
                  let uiImage = UIImage(data: jpegData)
            else {
                image = .failure
                return
            }
            image = .success(Image(uiImage: uiImage).resizable().scaledToFit())
            self.mapMapRawEncodedImage = jpegData
            self.imageWidth = rawPhoto.size.width
            self.imageHeight = rawPhoto.size.height
            generateThumbnailFromUIImage(uiImage)
        }
    }
}

// MARK: Perspective correction
extension MapMap {
    func applyPerspectiveCorrectionWithCorners() {
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
        let result: ImageStatus = .success(Image(uiImage: newUIImage).resizable().scaledToFit())
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
