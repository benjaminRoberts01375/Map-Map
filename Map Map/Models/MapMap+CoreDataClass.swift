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
        if let mapData = self.mapMapEncodedImage { // Available in Core Data
            if let uiImage = UIImage(data: mapData) {
                image = .success(
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                )
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
}

extension MapMap {
    convenience public init(rawPhoto: PhotosPickerItem?, insertInto context: NSManagedObjectContext) {
        self.init(context: context)
        thumbnail = .loading
        image = .loading
        self.mapMapName = "Untitled map"
        Task {
            if let mapData = try? await rawPhoto?.loadTransferable(type: Data.self) {
                self.mapMapEncodedImage = mapData
                if let uiImage = UIImage(data: mapData) {
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
