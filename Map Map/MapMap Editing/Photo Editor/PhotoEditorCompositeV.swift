//
//  PhotoEditorCompositeV.swift
//  Map Map
//
//  Created by Ben Roberts on 2/2/24.
//

import Bottom_Drawer
import SwiftUI
import Vision

struct PhotoEditorCompositeV: View {
    let mapMap: MapMap
    /// Dismiss function for the view.
    @Environment(\.dismiss) private var dismiss
    /// Positioning of handles.
    @State private var handleTracker: FourCornersStorage
    /// Screen space image size.
    @State private var screenSpaceImageSize: CGSize
    /// Track if the system is currently cropping an image.
    @State private var currentlyCropping: Bool = false
    
    init(mapMap: MapMap) {
        self.mapMap = mapMap
        if let corners = mapMap.cropCorners { self._handleTracker = State(initialValue: FourCornersStorage(corners: corners)) }
        else { self._handleTracker = State(initialValue: FourCornersStorage(fill: mapMap.imageSize)) }
        self._screenSpaceImageSize = State(initialValue: mapMap.imageSize)
    }
    
    var body: some View {
        ZStack {
            PhotoEditorV(mapMap: mapMap, handleTracker: $handleTracker, screenSpaceMapMapSize: $screenSpaceImageSize)
                .background(.black)
            BottomDrawer(verticalDetents: [.content], horizontalDetents: [.center], shortCardSize: 350) { isShortCard in
                HStack {
                    Button(
                        action: {
                            let inverseRatio = CGSize(width: mapMap.imageWidth, height: mapMap.imageHeight) / screenSpaceImageSize
                            let correctedCorners = handleTracker * inverseRatio
                            if !mapMap.checkSameCorners(correctedCorners) {
                                PhotoEditorV.perspectiveQueue.async {
                                    guard let croppedImage = mapMap.setAndApplyCorners(corners: correctedCorners)
                                    else {
                                        dismiss()
                                        return
                                    }
                                    DispatchQueue.main.async {
                                        mapMap.objectWillChange.send()
                                        dismiss()
                                    }
                                    mapMap.saveCroppedImage(image: croppedImage)
                                    return
                                }
                            }
                            else { dismiss() }
                        },
                        label: { Text("Crop").bigButton(backgroundColor: .blue) }
                    )
                    Button(
                        action: { reset() },
                        label: { Text("Reset").bigButton(backgroundColor: .gray) }
                    )
                    Button(
                        action: { dismiss() },
                        label: { Text("Cancel").bigButton(backgroundColor: .gray) }
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
