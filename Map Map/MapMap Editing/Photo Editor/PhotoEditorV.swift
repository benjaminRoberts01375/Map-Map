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
    @State var rotation: Angle
    
    /// Create a photo editor instance.
    /// - Parameters:
    ///   - mapMap: Map Map to edit photo for.
    ///   - handleTracker: Position of cropping handles.
    ///   - screenSpaceMapMapSize: Rendered size of photo.
    init(mapMap: MapMap, handleTracker: Binding<HandleTrackerM>, screenSpaceMapMapSize: Binding<CGSize>) {
        self.mapMap = mapMap
        self._handleTracker = handleTracker
        self._screenSpaceImageSize = screenSpaceMapMapSize
        switch handleTracker.orientation.wrappedValue {
        case .standard: rotation = .zero
        case .down: rotation = Angle(degrees: 180)
        case .left: rotation = Angle(degrees: 270)
        case .right: rotation = Angle(degrees: 90)
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                if handleTracker.autoCorners != nil {
                    Button {
                        guard let autoCorners = handleTracker.autoCorners
                        else { return }
                        withAnimation { handleTracker.stockCorners = autoCorners.copy() }
                    } label: {
                        Text("Auto Crop")
                            .padding()
                    }
                    .disabled(handleTracker.stockCorners == handleTracker.autoCorners)
                }
                Spacer()
                Button {
                    rotateLeft()
                } label: {
                    Image(systemName: "crop.rotate")
                        .resizable()
                        .scaledToFit()
                        .accessibilityLabel("MapMap counter clockwise 90º")
                        .frame(width: 25, height: 25)
                        .frame(width: 40, height: 40)
                }
                Button {
                    rotateRight()
                } label: {
                    Image(systemName: "crop.rotate")
                        .resizable()
                        .scaledToFit()
                        .accessibilityLabel("MapMap clockwise 90º")
                        .rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
                        .frame(width: 25, height: 25)
                        .frame(width: 40, height: 40)
                }
            }
            .frame(height: 55)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            GeometryReader { geo in
                ZStack(alignment: .center) {
                    let rotated = rotation.degrees.truncatingRemainder(dividingBy: 180) != .zero
                    let size = CGSize(
                        width: rotated ? geo.size.height : geo.size.width,
                        height: rotated ? geo.size.width : geo.size.height
                    )
                    MapMapV(mapMap, imageType: .originalImage)
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
            if mapMap.activeImage?.cropCorners == nil,
               let mapMapImageData = mapMap.activeImage?.imageData,
               let ciImage = CIImage(data: mapMapImageData),
               let generatedCorners = PhotoEditorV.detectDocumentCorners(image: ciImage, displaySize: screenSpaceImageSize) {
                DispatchQueue.main.async {
                    handleTracker.autoCorners = generatedCorners.copy()
                    handleTracker.stockCorners = generatedCorners
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
    static func detectDocumentCorners(image: CIImage, displaySize: CGSize) -> CropCornersStorage? {
        var corners: CropCornersStorage?
        let rectangleDetectionRequest = VNDetectRectanglesRequest { request, _ in
            guard let results = request.results as? [VNRectangleObservation], !results.isEmpty,
                  let rectangle = results.first // Get first rectangle
            else { return }
            
            // Scale coordinates from 0...1 to screen dimensions, and correct for upside down and mirror
            corners = CropCornersStorage(
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
    static func crop(corners: CropCornersStorage, orientation: Orientation, mapMapImage: MapMapImage, dismiss: @escaping () -> Void) {
        if !mapMapImage.checkSameCorners(corners) {
            PhotoEditorV.perspectiveQueue.async {
                guard let croppedImage = mapMapImage.setAndApplyCorners(corners: corners),
                      let moc = mapMapImage.managedObjectContext
                else {
                    dismiss()
                    return
                }
                DispatchQueue.main.async {
                    if mapMapImage.imageContainer?.unwrappedImages.count ?? 1 > 1, 
                        let oldCroppedImage = mapMapImage.imageContainer?.unwrappedImages.last {
                        moc.delete(oldCroppedImage)
                    }
                    dismiss()
                    guard let imageContainer = mapMapImage.imageContainer
                    else { return }
                    imageContainer.addToImages(MapMapImage(uiImage: croppedImage, orientation: orientation, moc: moc))
                }
            }
        }
        else { dismiss() }
    }
    
    /// Generate the ideal initial handle positions based on a given map map.
    /// - Parameter mapMap: Base map map.
    /// - Returns: A handle tracker that is correctly rotated for the map map.
    static func generateInitialHandles(baseMapMap mapMap: MapMap) -> HandleTrackerM {
        if let corners = mapMap.activeImage?.cropCorners, let orientation = mapMap.activeImage?.unwrappedOrientation {
            let handles: HandleTrackerM =
            switch orientation {
            case .standard: HandleTrackerM(stockCorners: CropCornersStorage(corners: corners))
            case .right: HandleTrackerM(stockCorners: CropCornersStorage(corners: corners).rotateLeft())
            case .down: HandleTrackerM(stockCorners: CropCornersStorage(corners: corners).rotateDown())
            case .left: HandleTrackerM(stockCorners: CropCornersStorage(corners: corners).rotateRight())
            }
            handles.orientation = orientation
            return handles
        }
        else { return HandleTrackerM(stockCorners: CropCornersStorage(fill: mapMap.activeImage?.imageSize ?? .zero)) }
    }
}
