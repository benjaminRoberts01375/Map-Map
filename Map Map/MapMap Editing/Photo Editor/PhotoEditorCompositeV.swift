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
    @State var loading: Bool = true
    /// Dismiss function for the view.
    @Environment(\.dismiss) private var dismiss
    
    @State private var handleTracker: FourCornersStorage
    
    /// Screen space image size.
    @State private var screenSpaceImageSize: CGSize
    
    private static let perspectiveQueue = DispatchQueue(label: "com.RobertsHousehold.MapMap.PerspectiveFixer", qos: .userInteractive)
    
    init(mapMap: MapMap) {
        self.mapMap = mapMap
        if let corners = mapMap.cropCorners {
            self._handleTracker = State(initialValue: FourCornersStorage(corners: corners))
        }
        else {
            let corners = FourCornersStorage(
                topLeading: .zero,
                topTrailing: CGSize(width: mapMap.imageWidth, height: .zero),
                bottomLeading: CGSize(width: .zero, height: mapMap.imageHeight),
                bottomTrailing: CGSize(width: mapMap.imageWidth, height: mapMap.imageHeight)
            )
            self._handleTracker = State(initialValue: corners)
        }
        self._screenSpaceImageSize = State(
            initialValue: CGSize(
                width: mapMap.imageWidth,
                height: mapMap.imageHeight
            )
        )
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                PhotoEditorV(mapMap: mapMap, handleTracker: $handleTracker, screenSpaceImageSize: geo.size)
                    .onViewResizes { _, update in
                        handleTracker *= update / self.screenSpaceImageSize
                            self.screenSpaceImageSize = update
                    }
                    .frame(
                        width: geo.size.width * 0.95,
                        height: geo.size.height * 0.72
                    )
            }
            BottomDrawer(verticalDetents: [.content], horizontalDetents: [.center], shortCardSize: 350) { isShortCard in
                HStack {
                    Button(
                        action: { triggerCrop() },
                        label: {
                            if loading { ProgressView().bigButton(backgroundColor: .blue.opacity(0.5)) }
                            else { Text("Crop").bigButton(backgroundColor: .blue) }
                        }
                    )
                    .disabled(loading)
                    Button(
                        action: { reset() },
                        label: { Text("Reset").bigButton(backgroundColor: .gray.opacity(loading ? 0.5 : 1)) }
                    )
                    .disabled(loading)
                    Button(
                        action: { dismiss() },
                        label: { Text("Cancel").bigButton(backgroundColor: .gray.opacity(loading ? 0.5 : 1)) }
                    )
                    .disabled(loading)
                }
                .padding(.bottom, isShortCard ? 0 : 10)
            }
        }
    }
    
    /// Sets up and triggers the crop function for a Map Map.
    private func triggerCrop() {
        loading = true
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
