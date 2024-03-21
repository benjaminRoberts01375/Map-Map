//
//  CameraV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/11/23.
//

import SwiftUI

/// Handle switching between the live camera and the camera output.
struct CameraV: View {
    @Environment(\.managedObjectContext) var moc
    @State private var cameraState: CameraState = .takingPhoto
    
    enum CameraState {
        case takingPhoto
        case editingPhoto(UIImage)
    }
    
    var body: some View {
        switch cameraState {
        case .takingPhoto:
            CameraPreviewV(photoPassthrough: $cameraState)
        case .editingPhoto(let image):
            let mapMap: MapMap = {
               let newMapMap = MapMap(uiImage: image, moc: moc)
                newMapMap.isEditing = false
                return newMapMap
            }()
            EditCameraPhotoV(mapMap: mapMap, cameraState: $cameraState)
        }
    }
}
