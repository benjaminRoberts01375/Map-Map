//
//  HandleV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/2/23.
//

import SwiftUI

/// Handle for dragging around.
struct HandleV: View {
    /// Position of the handle on screen.
    @Binding var position: CGSize
    /// How far the handle was dragged up to the last frame.
    @State private var previousFrameDragAmount: CGSize = .zero
    /// Size of the handle
    private let handleSize: CGFloat = 30
    
    var dragGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { update in
                position.width += update.translation.width - previousFrameDragAmount.width
                position.height += update.translation.height - previousFrameDragAmount.height
                previousFrameDragAmount = update.translation
            }
            .onEnded { _ in
                previousFrameDragAmount = .zero
            }
    }
    
    var body: some View {
        Circle()
            .frame(width: handleSize, height: handleSize)
            .foregroundStyle(.white.opacity(0.5))
            .position(x: position.width, y: position.height)
            .gesture(dragGesture)
            .shadow(radius: 2)
    }
}
