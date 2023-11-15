//
//  GridOverlayV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/15/23.
//

import SwiftUI

struct GridOverlayV: View {
    @Binding var handleTracker: HandleTrackerM
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            IrregularGridV(
                topLeading: handleTracker.topLeadingPoint,
                topTrailing: handleTracker.topTrailingPoint,
                bottomLeading: handleTracker.bottomLeadingPoint,
                bottomTrailing: handleTracker.bottomTrailingPoint
            )
            .fill(.clear)
            .stroke(.white.opacity(0.75), lineWidth: 2)
            
            HandleV(position: $handleTracker.topLeadingPoint)
            HandleV(position: $handleTracker.topTrailingPoint)
            HandleV(position: $handleTracker.bottomLeadingPoint)
            HandleV(position: $handleTracker.bottomTrailingPoint)
        }
    }
}
