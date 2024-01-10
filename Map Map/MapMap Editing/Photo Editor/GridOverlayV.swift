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
    @Binding var handleTracker: HandleTrackerM
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            IrregularGridV(
                topLeading: handleTracker.corners.topLeading,
                topTrailing: handleTracker.corners.topTrailing,
                bottomLeading: handleTracker.corners.bottomLeading,
                bottomTrailing: handleTracker.corners.bottomTrailing
            )
            .fill(.clear)
            .stroke(.black.opacity(0.75), lineWidth: 3)
            .stroke(.white.opacity(0.75), lineWidth: 2)
            
            HandleV(position: $handleTracker.corners.topLeading)
            HandleV(position: $handleTracker.corners.topTrailing)
            HandleV(position: $handleTracker.corners.bottomLeading)
            HandleV(position: $handleTracker.corners.bottomTrailing)
        }
    }
}
