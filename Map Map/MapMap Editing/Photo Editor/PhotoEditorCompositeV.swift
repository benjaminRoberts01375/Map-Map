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
    
    var body: some View {
        ZStack {
            PhotoEditorV(mapMap: mapMap)
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
        .task {
            if mapMap.cropCorners == nil,
               let mapMapImageData = mapMap.mapMapRawEncodedImage,
               let ciImage = CIImage(data: mapMapImageData),
               let generatedCorners = PhotoEditorCompositeV.detectDocumentCorners(image: ciImage, displaySize: screenSpaceImageSize) {
                DispatchQueue.main.async {
                    handleTracker = generatedCorners
                }
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
    
    /// Detect where the corners of a rectangle in a photo are.
    /// - Parameters:
    ///   - imageData: Raw data from an image.
    ///   - displaySize: Size of the photo currently being displayed.
    /// - Returns: Positions of corners if found.
    static func detectDocumentCorners(image: CIImage, displaySize: CGSize) -> FourCornersStorage? {
        var corners: FourCornersStorage?
        let rectangleDetectionRequest = VNDetectRectanglesRequest { request, _ in
            guard let results = request.results as? [VNRectangleObservation], !results.isEmpty,
                  let rectangle = results.first // Get first rectangle
            else { return }
            
            // Scale coordinates from 0...1 to screen dimensions, and correct for upside down and mirror
            corners = FourCornersStorage(
                topLeading: CGSize(
                    width: rectangle.topLeft.x * displaySize.width,
                    height: displaySize.height - rectangle.topLeft.y * displaySize.height
                ),
                topTrailing: CGSize(
                    width: rectangle.topRight.x * displaySize.width,
                    height: displaySize.height - rectangle.topRight.y * displaySize.height
                ),
                bottomLeading: CGSize(
                    width: rectangle.bottomLeft.x * displaySize.width,
                    height: displaySize.height - rectangle.bottomLeft.y * displaySize.height
                ),
                bottomTrailing: CGSize(
                    width: rectangle.bottomRight.x * displaySize.width,
                    height: displaySize.height - rectangle.bottomRight.y * displaySize.height
                )
            )
        }
        
        let handler = VNImageRequestHandler(ciImage: image, options: [:])
        try? handler.perform([rectangleDetectionRequest])
        return corners
    }
}
