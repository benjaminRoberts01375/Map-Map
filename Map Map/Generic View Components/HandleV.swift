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
    /// Default color to make the handle
    public static var defaultColor: Color = .white.opacity(0.5)
    /// Actual color of the handle
    public var color: Color = HandleV.defaultColor
    /// Defer moving the handle to caller view.
    public var deferPosition: Bool = false
    
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
        if deferPosition {
            Circle()
                .handleAppearance(color: color)
                .gesture(dragGesture)
        }
        else {
            Circle()
                .handleAppearance(color: color)
                .gesture(dragGesture)
                .position(x: position.width, y: position.height)
        }
    }
}

fileprivate struct HandleVModifier: ViewModifier {
    /// Size of the handle.
    public static let handleSize: CGFloat = 30
    /// Handle padding distance.
    public static let handlePadding: CGFloat = 10
    /// Color of the handle.
    public let color: Color
    
    func body(content: Content) -> some View {
        content
            .frame(width: HandleVModifier.handleSize, height: HandleVModifier.handleSize)
            .foregroundStyle(color)
            .shadow(radius: 2)
            .padding(HandleVModifier.handlePadding)
    }
}

extension View {
    func handleAppearance(color: Color = .white) -> some View {
        modifier(HandleVModifier(color: color))
    }
}
