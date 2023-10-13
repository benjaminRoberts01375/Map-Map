//
//  MapPhoto+CoreDataClass.swift
//  Map Map
//
//  Created by Ben Roberts on 10/8/23.
//
//

import CoreData
import PhotosUI
import SwiftUI

@objc(MapPhoto)
public class MapPhoto: NSManagedObject {
    private var image: ImageStatus = .empty {
        didSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    private var thumbnail: ImageStatus = .empty {
        didSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    private let thumbnailSize: CGSize = CGSize(width: 300, height: 300)
    public var isEditing: Bool = false
    
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
        if let mapData = self.map { // Available in Core Data
            if let uiImage = UIImage(data: mapData) {
                image = .success(
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                )
                if self.mapThumbnail == nil { generateThumbnailFromUIImage(uiImage) }
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
                self.mapThumbnail = generatedThumbnail.jpegData(compressionQuality: 0.8)
            }
            else {
                thumbnail = .failure
            }
        }
    }
    
    private func loadThumbnailFromCD() {
        if let mapThumbnail = self.mapThumbnail {
            if let uiImage = UIImage(data: mapThumbnail) {
                thumbnail = .success(Image(uiImage: uiImage).resizable().scaledToFit())
                return
            }
        }
        thumbnail = .failure
    }
}

extension MapPhoto {
    convenience public init(rawPhoto: PhotosPickerItem?, insertInto context: NSManagedObjectContext) {
        self.init(context: context)
        thumbnail = .loading
        image = .loading
        isEditing = true
        Task {
            if let mapData = try? await rawPhoto?.loadTransferable(type: Data.self) {
                self.map = mapData
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
    
    public func markAsComplete() {
        if mapName?.isEmpty ?? true { mapName = "Untitled"}
    }
    
    public func needsEditing() {
        isEditing = true
    }
}
