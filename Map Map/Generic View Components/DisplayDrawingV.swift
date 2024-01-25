//
//  DisplayDrawingV.swift
//  Map Map
//
//  Created by Ben Roberts on 1/22/24.
//

import PencilKit
import SwiftUI

struct DisplayDrawingV: UIViewRepresentable {
    let drawing: PKDrawing?
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView: PKCanvasView = PKCanvasView()
        canvasView.isOpaque = false
        canvasView.isUserInteractionEnabled = false
        if let drawing = drawing { canvasView.drawing = drawing }
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) { }
}
