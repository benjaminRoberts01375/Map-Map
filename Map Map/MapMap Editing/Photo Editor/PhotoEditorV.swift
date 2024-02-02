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
    var screenSpaceImageSize: CGSize
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .center) {
                MapMapV(mapMap: mapMap, mapType: .original)
                GridOverlayV(corners: $handleTracker)
                    .offset(
                        x: (geo.size.width - geo.size.width) / 2,
                        y: (geo.size.height - geo.size.height) / 2
                    )
            }
            .ignoresSafeArea()
        }
        .background(.black)
        .task {
            if mapMap.cropCorners == nil,
               let mapMapImageData = mapMap.mapMapRawEncodedImage,
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
