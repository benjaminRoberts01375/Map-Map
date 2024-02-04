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
    @Published public var image: ImageStatus = .empty
    @Published public var thumbnail: ImageStatus = .empty
    
    private func generateThumbnail() async {
        guard let imageData = imageData,
              let uiImage = UIImage(data: imageData),
              var thumbnail = await uiImage.byPreparingThumbnail(ofSize: MapImage.thumbnailSize)
        else {
            DispatchQueue.main.async { self.thumbnail = .failure }
            return
        }
        self.thumbnailData = thumbnail.jpegData(compressionQuality: 0.1)
    }
    
    func loadImageFromCD() {
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
    }
}
