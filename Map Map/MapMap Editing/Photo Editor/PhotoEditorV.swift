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
    /// The current MapMap whos photo is being edited.
    let mapMap: FetchedResults<MapMap>.Element
    /// Crop handle positions.
    @Binding var handleTracker: FourCornersStorage
    /// Screen space image size.
    @Binding var screenSpaceImageSize: CGSize
    /// Dispatch queue for cropping images.
    static let perspectiveQueue = DispatchQueue(label: "com.RobertsHousehold.MapMap.PerspectiveFixer", qos: .userInteractive)
    
    /// Create a photo editor instance.
    /// - Parameters:
    ///   - mapMap: Map Map to edit photo for.
    ///   - handleTracker: Position of cropping handles.
    ///   - screenSpaceMapMapSize: Rendered size of photo.
    init(mapMap: MapMap, handleTracker: Binding<FourCornersStorage>, screenSpaceMapMapSize: Binding<CGSize>) {
        self.mapMap = mapMap
        self._handleTracker = handleTracker
        self._screenSpaceImageSize = screenSpaceMapMapSize
    }
    
    var body: some View {
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
                    .offset(x: (geo.size.width - screenSpaceImageSize.width) / 2, y: (geo.size.height - screenSpaceImageSize.height) / 2)
            }
        }
        .task {
            if mapMap.cropCorners == nil,
               let mapMapImageData = mapMap.imageDefault?.imageData,
               let ciImage = CIImage(data: mapMapImageData),
               let generatedCorners = PhotoEditorV.detectDocumentCorners(image: ciImage, displaySize: screenSpaceImageSize) {
                DispatchQueue.main.async {
                    handleTracker = generatedCorners
                }
            }
        }
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
