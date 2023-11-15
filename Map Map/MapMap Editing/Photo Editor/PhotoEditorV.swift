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
                    MapMapV(mapMap: mapMap)
                        .background {
                            GeometryReader { imageGeo in
                                Color.clear
                                    .onChange(of: imageGeo.size, initial: true) { _, update in
                                        screenSpaceImageSize = update
                                        let scaleRatio = screenSpaceImageSize / CGSize(width: mapMap.imageWidth, height: mapMap.imageHeight)
                                        handleTracker.topLeadingPoint *= scaleRatio
                                        handleTracker.topTrailingPoint *= scaleRatio
                                        handleTracker.bottomLeadingPoint *= scaleRatio
                                        handleTracker.bottomTrailingPoint *= scaleRatio
                                    }
                            }
                        }
                        .frame(
                            width: geo.size.width - 100,
                            height: geo.size.height * 0.72
                        )
                    
                    IrregularGridV(
                        topLeading: handleTracker.topLeadingPoint,
                        topTrailing: handleTracker.topTrailingPoint,
                        bottomLeading: handleTracker.bottomLeadingPoint,
                        bottomTrailing: handleTracker.bottomTrailingPoint
                    )
                    .fill(.clear)
                    .stroke(.white.opacity(0.75), lineWidth: 2)
                    .offset(
                        x: (geo.size.width - screenSpaceImageSize.width) / 2,
                        y: (geo.size.height - screenSpaceImageSize.height) / 2
                    )
                    
                    ZStack(alignment: .topLeading) {
                        HandleV(position: $handleTracker.topLeadingPoint)
                        HandleV(position: $handleTracker.topTrailingPoint)
                        HandleV(position: $handleTracker.bottomLeadingPoint)
                        HandleV(position: $handleTracker.bottomTrailingPoint)
                    }
                    .offset(
                        x: (geo.size.width - screenSpaceImageSize.width) / 2,
                        y: (geo.size.height - screenSpaceImageSize.height) / 2
                    )
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
                            mapMap.setCorners(
                                topLeading: handleTracker.topLeadingPoint * inverseRatio,
                                topTrailing: handleTracker.topTrailingPoint * inverseRatio,
                                bottomLeading: handleTracker.bottomLeadingPoint * inverseRatio,
                                bottomTrailing: handleTracker.bottomTrailingPoint * inverseRatio
                            )
                            mapMap.applyPerspectiveCorrectionWithCorners() // Causes lockup
                            print("Dismissing")
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
                        handleTracker.topLeadingPoint = .zero
                        handleTracker.topTrailingPoint = CGSize(width: screenSpaceImageSize.width, height: .zero)
                        handleTracker.bottomLeadingPoint = CGSize(width: .zero, height: screenSpaceImageSize.height)
                        handleTracker.bottomTrailingPoint = screenSpaceImageSize
                        mapMap.cropCorners = nil
                        mapMap.mapMapPerspectiveFixedEncodedImage = nil
                    } label: {
                        Text("Reset")
                            .bigButton(backgroundColor: .gray)
                    }
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .bigButton(backgroundColor: .gray)
                    }
                }
            }
        }
    }
}
