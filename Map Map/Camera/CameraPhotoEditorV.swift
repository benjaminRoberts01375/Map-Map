//
//  EditCameraPhotoV.swift
//  Map Map
//
//  Created by Ben Roberts on 2/6/24.
//

import Bottom_Drawer
import SwiftUI

struct EditCameraPhotoV: View {
    /// The NSManagedObjectContext being saved and read from.
    @Environment(\.managedObjectContext) var moc
    /// MapMap with image being edited.
    @ObservedObject var mapMap: MapMap
    /// Current step for processing a taken photo.
    @Binding var cameraState: CameraV.CameraState
    /// Positioning of handles.
    @State private var handleTracker: FourCornersStorage
    /// Screen space image size.
    @State private var screenSpaceImageSize: CGSize
    /// Track if the system is currently cropping an image.
    @State private var currentlyCropping: Bool = false
    /// Image dimensions of the mapMap.
    private let imageDimensions: CGSize
    
    init(mapMap: MapMap, cameraState: Binding<CameraV.CameraState>) {
        self.mapMap = mapMap
        self._cameraState = cameraState
        if let corners = mapMap.cropCorners { self._handleTracker = State(initialValue: FourCornersStorage(corners: corners)) }
        else { self._handleTracker = State(initialValue: FourCornersStorage(fill: mapMap.activeImage?.size ?? .zero)) }
        self._screenSpaceImageSize = State(initialValue: mapMap.activeImage?.size ?? .zero)
        self.imageDimensions = mapMap.imageSize ?? .zero
    }
    
    var body: some View {
        ZStack {
            PhotoEditorV(mapMap: mapMap, handleTracker: $handleTracker, screenSpaceMapMapSize: $screenSpaceImageSize)
                .background(.black)
            BottomDrawer(verticalDetents: [.content], horizontalDetents: [.center], shortCardSize: 350) { isShortCard in
                HStack {
                    Button(
                        action: {
                            let inverseRatio = imageDimensions / screenSpaceImageSize
                            let correctedCorners = handleTracker * inverseRatio
                            if !mapMap.checkSameCorners(correctedCorners) {
                                PhotoEditorV.perspectiveQueue.async {
                                    guard let croppedImage = mapMap.setAndApplyCorners(corners: correctedCorners)
                                    else {
                                        mapMap.isEditing = true
                                        return
                                    }
                                    DispatchQueue.main.async {
                                        mapMap.isEditing = true
                                        let mapImage = MapImage(image: croppedImage, type: .cropped, moc: moc)
                                        mapMap.addToImages(mapImage)
                                    }
                                }
                            }
                            else { mapMap.isEditing = true }
                        },
                        label: { Text("Crop").bigButton(backgroundColor: .blue) }
                    )
                    Button(
                        action: { reset() },
                        label: { Text("Reset").bigButton(backgroundColor: .gray) }
                    )
                    Button(
                        action: { cameraState = .takingPhoto },
                        label: { Text("Retake").bigButton(backgroundColor: .red) }
                    )
                }
                .padding(.bottom, isShortCard ? 0 : 10)
            }
        }
    }
    
    /// Reset the MapMap crop back to none.
    private func reset() {
        handleTracker.topLeading = .zero
        handleTracker.topTrailing = CGSize(width: screenSpaceImageSize.width, height: .zero)
        handleTracker.bottomLeading = CGSize(width: .zero, height: screenSpaceImageSize.height)
        handleTracker.bottomTrailing = screenSpaceImageSize
        mapMap.cropCorners = nil
    }
}
