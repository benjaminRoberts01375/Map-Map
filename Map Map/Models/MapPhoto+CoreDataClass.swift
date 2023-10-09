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
    @Published var image: ImageStatus = .loading
    
    enum ImageStatus {
        case loading
        case success(Image)
        case failure
    }
}

extension MapPhoto {
    convenience public init(rawPhoto: PhotosPickerItem?, insertInto context: NSManagedObjectContext) {
        self.init(context: context)
        Task {
            if let data = try? await rawPhoto?.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    self.image = .success(Image(uiImage: uiImage))
                    self.objectWillChange.send()
                    return
                }
            }
            self.image = .failure
        }
    }
}
