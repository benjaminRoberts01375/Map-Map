//
//  PhotoEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/31/23.
//

import Bottom_Drawer
import CoreImage
import SwiftUI
import Vision

/// Make crop edits to the photo editor.
struct PhotoEditorV: View {
    /// Dismiss function for the view.
    @Environment(\.dismiss) private var dismiss
    /// The current MapMap whos photo is being edited.
    private let mapMap: FetchedResults<MapMap>.Element
    /// Crop handle positions.
    @State private var handleTracker: FourCornersStorage
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
                ZStack(alignment: .center) {
                    MapMapV(mapMap: mapMap, mapType: .original)
                        .onViewResizes { _, update in
                            handleTracker *= update / self.screenSpaceImageSize
                            self.screenSpaceImageSize = update
                        }
                        .frame(
                            width: geo.size.width * 0.95,
                            height: geo.size.height * 0.72
                        )
                    
                    GridOverlayV(corners: $handleTracker)
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
        .task {
            if mapMap.cropCorners == nil, let generatedCorners = detectDocumentCorners() {
                DispatchQueue.main.async {
                    handleTracker = generatedCorners
                }
            }
        }
    }
    
    /// Sets up and triggers the crop function for a Map Map.
    private func triggerCrop() {
        loading = true
        PhotoEditorV.perspectiveQueue.async {
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
    
    /// Detect where the corners of a rectangle in a photo are.
    /// - Returns: Positions of corners if found.
    func detectDocumentCorners() -> FourCornersStorage? {
        guard let imageData = mapMap.mapMapRawEncodedImage,
              let ciImage = CIImage(data: imageData)
        else { return nil }
        
        var corners: FourCornersStorage?
        let rectangleDetectionRequest = VNDetectRectanglesRequest { request, _ in
            guard let results = request.results as? [VNRectangleObservation], !results.isEmpty,
                  let rectangle = results.first // Get first rectangle
            else { return }
            
            // Scale coordinates from 0...1 to screen dimensions, and correct for upside down and mirror
            corners = FourCornersStorage(
                topLeading: CGSize(
                    width: rectangle.topLeft.x * screenSpaceImageSize.width,
                    height: screenSpaceImageSize.height - rectangle.topLeft.y * screenSpaceImageSize.height
                ),
                topTrailing: CGSize(
                    width: rectangle.topRight.x * screenSpaceImageSize.width,
                    height: screenSpaceImageSize.height - rectangle.topRight.y * screenSpaceImageSize.height
                ),
                bottomLeading: CGSize(
                    width: rectangle.bottomLeft.x * screenSpaceImageSize.width,
                    height: screenSpaceImageSize.height - rectangle.bottomLeft.y * screenSpaceImageSize.height
                ),
                bottomTrailing: CGSize(
                    width: rectangle.bottomRight.x * screenSpaceImageSize.width,
                    height: screenSpaceImageSize.height - rectangle.bottomRight.y * screenSpaceImageSize.height
                )
            )
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        try? handler.perform([rectangleDetectionRequest])
        return corners
    }
}
