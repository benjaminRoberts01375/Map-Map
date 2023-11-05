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
}

extension MapMap {
    func applyPerspectiveCorrectionWithCorners() {
        guard let imageData = self.mapMapRawEncodedImage,       // Type Data
              let uiImage = UIImage(data: consume imageData),   // Type uiImage
              let ciImage = CIImage(image: consume uiImage),    // Type ciImage
              let fourCorners = self.cropCorners,               // Ensure fourCorners exists
              let filter = CIFilter(name: "CIPerspectiveCorrection")
        else { return }
        let context = CIContext()

        filter.setValue(CIVector(cgSize: fourCorners.topLeading), forKey: "inputBottomLeft")
        filter.setValue(CIVector(cgSize: fourCorners.topTrailing), forKey: "inputBottomRight")
        filter.setValue(CIVector(cgSize: fourCorners.bottomLeading), forKey: "inputTopLeft")
        filter.setValue(CIVector(cgSize: fourCorners.bottomTrailing), forKey: "inputTopRight")
        filter.setValue(consume ciImage, forKey: kCIInputImageKey)
        
        guard let newCIImage = filter.outputImage,
              let newCGImage = context.createCGImage(newCIImage, from: newCIImage.extent)
        else { return }
        
        let newUIImage = UIImage(cgImage: consume newCGImage)
        image = .success(Image(uiImage: newUIImage).resizable().scaledToFit())
        self.mapMapPerspectiveFixedEncodedImage = newUIImage.jpegData(compressionQuality: 0.9)
    }
}
