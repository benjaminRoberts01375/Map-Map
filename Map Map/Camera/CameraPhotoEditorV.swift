//
//  EditCameraPhotoV.swift
//  Map Map
//
//  Created by Ben Roberts on 2/6/24.
//

import Bottom_Drawer
import SwiftUI

struct EditCameraPhotoV: View {
    /// The current managed object context for this view.
    @Environment(\.managedObjectContext) var moc
    /// MapMap with image being edited.
    @ObservedObject var mapMap: MapMap
    /// Current step for processing a taken photo.
    @Binding var cameraState: CameraV.CameraState
    /// Positioning of handles.
    @State private var handleTracker: HandleTrackerM
    /// Screen space image size.
    @State private var screenSpaceImageSize: CGSize
    /// Track if the system is currently cropping an image.
    @State private var currentlyCropping: Bool = false
    /// Image dimensions of the mapMap.
    private let imageDimensions: CGSize
    
    init(mapMap: MapMap, cameraState: Binding<CameraV.CameraState>) {
        self.mapMap = mapMap
        self._cameraState = cameraState
        self._handleTracker = State(initialValue: PhotoEditorV.generateInitialHandles(baseMapMap: mapMap))
        self._screenSpaceImageSize = State(initialValue: mapMap.activeImage?.imageSize ?? .zero)
        self.imageDimensions = mapMap.activeImage?.imageSize ?? .zero
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
                            let correctedCorners = handleTracker.rotatedStockCorners * inverseRatio
                            guard let originalImage = mapMap.originalImage else { return }
                            if let mapImage = mapMap.activeImage, !mapImage.checkSameCorners(correctedCorners) {
                                PhotoEditorV.crop(
                                    corners: correctedCorners,
                                    orientation: handleTracker.orientation,
                                    mapMapImage: originalImage,
                                    dismiss: { mapMap.isEditing = true }
                                )
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
        handleTracker.stockCorners.topLeading = .zero
        handleTracker.stockCorners.topTrailing = CGSize(width: screenSpaceImageSize.width, height: .zero)
        handleTracker.stockCorners.bottomLeading = CGSize(width: .zero, height: screenSpaceImageSize.height)
        handleTracker.stockCorners.bottomTrailing = screenSpaceImageSize
        if let cropCorners = mapMap.activeImage?.cropCorners { moc.delete(cropCorners) }
    }
}
