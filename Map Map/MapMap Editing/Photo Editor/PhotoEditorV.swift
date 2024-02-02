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
        }
        .animation(.easeInOut, value: loading)
    }
}
