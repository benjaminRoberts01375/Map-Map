//
//  PhotoEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/31/23.
//

import Bottom_Drawer
import CoreImage
import SwiftUI

struct PhotoEditorV: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.pixelLength) var pixelLength
    
    let mapMap: FetchedResults<MapMap>.Element
    @State var handleTracker: HandleTrackerM
    @State var screenSpaceImageSize: CGSize = .zero
    
    @State var loading: Bool = false
    private static let perspectiveQueue = DispatchQueue(label: "com.RobertsHousehold.MapMap.PerspectiveFixer", qos: .userInteractive)
    
    init(mapMap: FetchedResults<MapMap>.Element) {
        self.mapMap = mapMap
        if let corners = mapMap.cropCorners { // If there are pre-defined corners, set those up
            self._handleTracker = State(initialValue: HandleTrackerM(corners: corners))
        }
        else { // No predefined corners, set corners to the actual corners of the photo
            self._handleTracker = State(initialValue: HandleTrackerM(width: mapMap.imageWidth, height: mapMap.imageHeight))
        }
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                ZStack(alignment: .center) {
                    MapMapV(mapMap: mapMap, mapType: .original)
                        .background {
                            GeometryReader { imageGeo in
                                Color.clear
                                    .onChange(of: imageGeo.size, initial: true) { _, update in
                                        screenSpaceImageSize = update
                                        let scaleRatio = screenSpaceImageSize / CGSize(width: mapMap.imageWidth, height: mapMap.imageHeight)
                                        handleTracker.corners.topLeading *= scaleRatio
                                        handleTracker.corners.topTrailing *= scaleRatio
                                        handleTracker.corners.bottomLeading *= scaleRatio
                                        handleTracker.corners.bottomTrailing *= scaleRatio
                                    }
                            }
                        }
                        .frame(
                            width: geo.size.width - 100,
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
            
            BottomDrawer(verticalDetents: [.content], horizontalDetents: [.center], shortCardSize: 350) { _ in
                HStack {
                    Button {
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
                    } label: {
                        if loading {
                            ProgressView()
                                .bigButton(backgroundColor: .blue.opacity(0.5))
                        }
                        else {
                            Text("Crop")
                                .bigButton(backgroundColor: .blue)
                        }
                    }
                    .disabled(loading)
                    Button {
                        handleTracker.corners.topLeading = .zero
                        handleTracker.corners.topTrailing = CGSize(width: screenSpaceImageSize.width, height: .zero)
                        handleTracker.corners.bottomLeading = CGSize(width: .zero, height: screenSpaceImageSize.height)
                        handleTracker.corners.bottomTrailing = screenSpaceImageSize
                        mapMap.cropCorners = nil
                    } label: {
                        Text("Reset")
                            .bigButton(backgroundColor: .gray.opacity(loading ? 0.5 : 1))
                    }
                    .disabled(loading)
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .bigButton(backgroundColor: .gray.opacity(loading ? 0.5 : 1))
                    }
                    .disabled(loading)
                }
            }
        }
        .animation(.easeInOut, value: loading)
    }
}
