//
//  MarkupEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 1/20/24.
//

import PencilKit
import SwiftUI

/// UIKit wrapper for PKCanvasView.
struct DrawingView: UIViewRepresentable {
    /// Canvas for displaying PKDrawings.
    @Binding var canvasView: PKCanvasView
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 15)
        canvasView.drawingPolicy = .anyInput
        canvasView.isOpaque = false
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}
