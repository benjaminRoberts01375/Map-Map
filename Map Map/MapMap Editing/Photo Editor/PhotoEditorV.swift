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
    @Binding var handleTracker: HandleTrackerM
    /// Screen space image size.
    @Binding var screenSpaceImageSize: CGSize
    /// Dispatch queue for cropping images.
    static let perspectiveQueue = DispatchQueue(label: "com.RobertsHousehold.MapMap.PerspectiveFixer", qos: .userInteractive)
    /// Track rotation amount.
    @State var rotation: Angle = .zero
    
    /// Create a photo editor instance.
    /// - Parameters:
    ///   - mapMap: Map Map to edit photo for.
    ///   - handleTracker: Position of cropping handles.
    ///   - screenSpaceMapMapSize: Rendered size of photo.
    init(mapMap: MapMap, handleTracker: Binding<HandleTrackerM>, screenSpaceMapMapSize: Binding<CGSize>) {
        self.mapMap = mapMap
        self._handleTracker = handleTracker
        self._screenSpaceImageSize = screenSpaceMapMapSize
    }
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    print("Auto handles")
                } label: {
                    Text("Auto")
                        .padding()
                }
                Spacer()
                Button {
                    rotateLeft()
                } label: {
                    Image(systemName: "rotate.left")
                        .accessibilityLabel("MapMap counter clockwise 90º")
                        .padding()
                }
                Button {
                    rotateRight()
                } label: {
                    Image(systemName: "rotate.right")
                        .accessibilityLabel("MapMap clockwise 90º")
                        .padding()
                }
            }
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            GeometryReader { geo in
                ZStack(alignment: .center) {
                    let rotated = rotation.degrees.truncatingRemainder(dividingBy: 180) != .zero
                    let size = CGSize(
                        width: rotated ? geo.size.height : geo.size.width,
                        height: rotated ? geo.size.width : geo.size.height
                    )
                    MapMapV(mapMap: mapMap, mapType: .original)
                        .onViewResizes { _, update in
                            handleTracker.stockCorners *= update / self.screenSpaceImageSize
                            self.screenSpaceImageSize = update
                        }
                        .frame(
                            width: size.width * 0.95,
                            height: size.height * 0.72
                        )
                        .position(CGPoint(size: geo.size / 2))
                    GridOverlayV(corners: $handleTracker.stockCorners)
                        .offset(
                            x: (geo.size.width - screenSpaceImageSize.width) / 2,
                            y: (geo.size.height - screenSpaceImageSize.height) / 2
                        )
                }
                .rotationEffect(rotation)
            }
        }
        .task {
            if mapMap.cropCorners == nil,
               let mapMapImageData = mapMap.imageDefault?.imageData,
               let ciImage = CIImage(data: mapMapImageData),
               let generatedCorners = PhotoEditorV.detectDocumentCorners(image: ciImage, displaySize: screenSpaceImageSize) {
                DispatchQueue.main.async {
                    handleTracker.autoCorners = generatedCorners
                }
            }
        }
    }
    
    /// Rotate the image to the left.
    private func rotateLeft() {
        withAnimation { rotation += Angle(degrees: -90) }
        if rotation.degrees <= -360 { rotation = .zero }
        updateHandleOrientation()
    }
    
    /// Rotate the image to the right.
    private func rotateRight() {
        withAnimation { rotation += Angle(degrees: 90) }
        if rotation.degrees >= 360 { rotation = .zero }
        updateHandleOrientation()
    }
    
    /// Convert rotation to hard degrees.
    private func updateHandleOrientation() {
        switch rotation.degrees {
        case 90, -270: handleTracker.orientation = .right
        case 180, -180: handleTracker.orientation = .down
        case 270, -90: handleTracker.orientation = .left
        default: handleTracker.orientation = .standard
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
    
    /// Crop map map to corrected corners.
    /// - Parameters:
    ///   - corners: Corners to crop the default map image to.
    ///   - mapMap: Map Map to crop.
    ///   - dismiss: What to do once created.
    static func crop(corners: FourCornersStorage, orientation: Orientation, mapMap: MapMap, dismiss: @escaping () -> Void) {
        if !mapMap.checkSameCorners(corners) {
            PhotoEditorV.perspectiveQueue.async {
                guard let croppedImage = mapMap.setAndApplyCorners(corners: corners),
                      let moc = mapMap.managedObjectContext
                else {
                    dismiss()
                    return
                }
                DispatchQueue.main.async {
                    dismiss()
                    let mapImage = MapImage(image: croppedImage, type: .cropped, orientation: orientation, moc: moc)
                    mapMap.addToImages(mapImage)
                }
            }
        }
        else { dismiss() }
    }
}
