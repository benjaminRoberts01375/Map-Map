//
//  PhotoEditorCompositeV.swift
//  Map Map
//
//  Created by Ben Roberts on 2/2/24.
//

import Bottom_Drawer
import SwiftUI

struct PhotoEditorCompositeV: View {
    /// MapMap with image being edited.
    let mapMap: MapMap
    /// Dismiss function for the view.
    @Environment(\.dismiss) private var dismiss
    /// Positioning of handles.
    @State private var handleTracker: HandleTrackerM
    /// Screen space image size.
    @State private var screenSpaceImageSize: CGSize
    /// Track if the system is currently cropping an image.
    @State private var currentlyCropping: Bool = false
    /// Image dimensions of the mapMap.
    private let imageDimensions: CGSize
    
    init(mapMap: MapMap) {
        self.mapMap = mapMap
        if let corners = mapMap.cropCorners {
            self._handleTracker = State(
                initialValue: HandleTrackerM(
                    stockCorners: FourCornersStorage(corners: corners)
                )
            )
        }
        else {
            self._handleTracker = State(
                initialValue: HandleTrackerM(
                    stockCorners: FourCornersStorage(fill: mapMap.imageDefault?.size ?? .zero)
                )
            )
        }
        self._screenSpaceImageSize = State(initialValue: mapMap.imageDefault?.size ?? .zero)
        self.imageDimensions = mapMap.imageDefault?.size ?? .zero
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
                            PhotoEditorV.crop(
                                corners: correctedCorners,
                                mapMap: mapMap,
                                dismiss: { dismiss() }
                            )
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
        handleTracker.stockCorners.topLeading = .zero
        handleTracker.stockCorners.topTrailing = CGSize(width: screenSpaceImageSize.width, height: .zero)
        handleTracker.stockCorners.bottomLeading = CGSize(width: .zero, height: screenSpaceImageSize.height)
        handleTracker.stockCorners.bottomTrailing = screenSpaceImageSize
        mapMap.cropCorners = nil
    }
}
