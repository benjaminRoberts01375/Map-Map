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
    var image: ImageStatus = .loading(ProgressView())
    
    enum ImageStatus {
        case loading(any View)
        case success(any View)
        case failure(any View)
    }
}

extension MapPhoto {
    convenience public init(rawPhoto: PhotosPickerItem?, insertInto context: NSManagedObjectContext) {
        self.init(context: context)
        Task {
            if let data = try? await rawPhoto?.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    self.image = .success(
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                    )
                    self.map = data
                    return
                }
            }
            self.image = .failure(
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.yellow)
            )
        }
    }
}
