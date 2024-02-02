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
    }
}
