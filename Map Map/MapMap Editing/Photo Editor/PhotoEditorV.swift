//
//  PhotoEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/31/23.
//

import Bottom_Drawer
import CoreImage
import SwiftUI

/// Make crop edits to the photo editor.
struct PhotoEditorV: View {
    /// Dismiss function for the view.
    @Environment(\.dismiss) private var dismiss
    /// The current MapMap whos photo is being edited.
    private let mapMap: FetchedResults<MapMap>.Element
    /// Crop handle positions.
    @State private var handleTracker: HandleTrackerM
    /// Screen space image size.
    @State private var screenSpaceImageSize: CGSize = .zero
    /// Track if image is being cropped and is taking a while.
    @State private var loading: Bool = false
    /// Create a dispatch queue for multithreading
    private static let perspectiveQueue = DispatchQueue(label: "com.RobertsHousehold.MapMap.PerspectiveFixer", qos: .userInteractive)
    
    /// Create an editor for fixing the perspective of MapMap photos.
    /// - Parameter mapMap: MapMap to edit.
    init(mapMap: FetchedResults<MapMap>.Element) {
        self.mapMap = mapMap
        if let corners = mapMap.cropCorners { // If there are pre-defined corners, set those up
            self._handleTracker = State(initialValue: HandleTrackerM(corners: corners))
        }
        else { // No predefined corners, set corners to the actual corners of the photo
            self._handleTracker = State(initialValue: HandleTrackerM(corners: .zero))
        }
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                ZStack(alignment: .center) {
                    MapMapV(mapMap: mapMap, mapType: .original)
                        .onViewResizes { previous, update in
                            if update == previous {
                                handleTracker.corners.topLeading = .zero
                                handleTracker.corners.bottomLeading = CGSize(width: .zero, height: update.height)
                                handleTracker.corners.topTrailing = CGSize(width: update.width, height: .zero)
                                handleTracker.corners.bottomTrailing = update
                            }
                            screenSpaceImageSize = update
                            handleTracker.corners *= previous / update
                        }
                        .frame(
                            width: geo.size.width * 0.95,
                            height: geo.size.height * 0.72
                        )
                    
                    GridOverlayV(handleTracker: $handleTracker)
                        .offset(
                            x: (geo.size.width - screenSpaceImageSize.width) / 2,
                            y: (geo.size.height - screenSpaceImageSize.height) / 2
                        )
                        .allowsHitTesting(!loading)
                        .opacity(loading ? 0.5 : 1)
                }
            }
            .ignoresSafeArea()
            .background(.black)
            
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
        .animation(.easeInOut, value: loading)
    }
    
    /// Sets up and triggers the crop function for a Map Map.
    private func triggerCrop() {
        loading = true
        PhotoEditorV.perspectiveQueue.async {
            let inverseRatio = CGSize(width: mapMap.imageWidth, height: mapMap.imageHeight) / screenSpaceImageSize
            mapMap.setAndApplyCorners(
                topLeading: handleTracker.corners.topLeading * inverseRatio,
                topTrailing: handleTracker.corners.topTrailing * inverseRatio,
                bottomLeading: handleTracker.corners.bottomLeading * inverseRatio,
                bottomTrailing: handleTracker.corners.bottomTrailing * inverseRatio
            )
            DispatchQueue.main.async {
                dismiss()
            }
        }
    }
    
    /// Reset the MapMap crop back to none.
    private func reset() {
        handleTracker.corners.topLeading = .zero
        handleTracker.corners.topTrailing = CGSize(width: screenSpaceImageSize.width, height: .zero)
        handleTracker.corners.bottomLeading = CGSize(width: .zero, height: screenSpaceImageSize.height)
        handleTracker.corners.bottomTrailing = screenSpaceImageSize
        mapMap.cropCorners = nil
    }
}
