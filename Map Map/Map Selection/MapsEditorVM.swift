//
//  MapEditorVM.swift
//  Map Map
//
//  Created by Ben Roberts on 10/8/23.
//

import CoreData
import PhotosUI
import SwiftUI

final class MapsContainer: ObservableObject {
    var rawPhotos: [PhotosPickerItem]
    
    init(rawPhotos: [PhotosPickerItem]) {
        self.rawPhotos = rawPhotos
    }
    
    func convertPhotosPickerItem(moc: NSManagedObjectContext) {
        for rawPhoto in rawPhotos {
            let _ = MapPhoto(rawPhoto: rawPhoto, insertInto: moc)
        }
        rawPhotos = []
    }
}
