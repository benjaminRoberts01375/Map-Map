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
    
    @State private var handleTracker: FourCornersStorage
    
    /// Screen space image size.
    @State private var screenSpaceImageSize: CGSize
    
    private static let perspectiveQueue = DispatchQueue(label: "com.RobertsHousehold.MapMap.PerspectiveFixer", qos: .userInteractive)
    
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
                        action: { triggerCrop() },
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
    
    /// Sets up and triggers the crop function for a Map Map.
    private func triggerCrop() {
        PhotoEditorCompositeV.perspectiveQueue.async {
            let inverseRatio = CGSize(width: mapMap.imageWidth, height: mapMap.imageHeight) / screenSpaceImageSize
            mapMap.setAndApplyCorners(
                topLeading: handleTracker.topLeading * inverseRatio,
                topTrailing: handleTracker.topTrailing * inverseRatio,
                bottomLeading: handleTracker.bottomLeading * inverseRatio,
                bottomTrailing: handleTracker.bottomTrailing * inverseRatio
            )
            DispatchQueue.main.async {
                dismiss()
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
