//
//  MapEditorVM.swift
//  Map Map
//
//  Created by Ben Roberts on 10/8/23.
//

import Combine
import CoreData
import PhotosUI
import SwiftUI

final class MapContainer: ObservableObject {
    @Published var processedPhotos: [MapPhoto] = []
    let rawPhotos: [PhotosPickerItem]
    var cancellables = Set<AnyCancellable>()
    
    init(rawPhotos: [PhotosPickerItem]) {
        self.rawPhotos = rawPhotos
    }
    
    func convertPhotosPickerItem(moc: NSManagedObjectContext) {
        var processing: [MapPhoto] = []
        for rawPhoto in rawPhotos {
            let map = MapPhoto(rawPhoto: rawPhoto, insertInto: moc)
            
            map.objectWillChange.sink { _ in
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            }
            .store(in: &cancellables)
            processing.append(map)
        }
        processedPhotos = processing // Prevent several reloads
    }
}
