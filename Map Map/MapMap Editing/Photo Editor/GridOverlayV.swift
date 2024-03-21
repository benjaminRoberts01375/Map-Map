//
//  GridOverlayV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/15/23.
//

import SwiftUI

/// Render grid with handles.
struct GridOverlayV: View {
    /// Grid corner positions.
    @Binding var corners: CropCornersStorage
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            IrregularGridV(
                topLeading: corners.topLeading,
                topTrailing: corners.topTrailing,
                bottomLeading: corners.bottomLeading,
                bottomTrailing: corners.bottomTrailing
            )
            .fill(.clear)
            .stroke(.black.opacity(0.75), lineWidth: 3)
            .stroke(.white.opacity(0.75), lineWidth: 2)
            
            HandleV(position: $corners.topLeading)
            HandleV(position: $corners.topTrailing)
            HandleV(position: $corners.bottomLeading)
            HandleV(position: $corners.bottomTrailing)
            CropGrabberV(leadingPoint: $corners.topLeading, trailingPoint: $corners.topTrailing)
            CropGrabberV(leadingPoint: $corners.topLeading, trailingPoint: $corners.bottomLeading)
            CropGrabberV(leadingPoint: $corners.topTrailing, trailingPoint: $corners.bottomTrailing)
            CropGrabberV(leadingPoint: $corners.bottomLeading, trailingPoint: $corners.bottomTrailing)
        }
    }
}
