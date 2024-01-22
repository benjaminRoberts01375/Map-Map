//
//  MarkupEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 1/20/24.
//

import Bottom_Drawer
import PencilKit
import SwiftUI

struct MarkupEditorV: View {
    @ObservedObject var mapMap: FetchedResults<MapMap>.Element
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @State private var canvasView: PKCanvasView
    @State private var toolPicker = PKToolPicker()
    @State private var mapMapSize: CGSize = .zero
    
    init(mapMap: FetchedResults<MapMap>.Element) {
        self.mapMap = mapMap
        let canvasView = PKCanvasView()
        if let drawing = mapMap.drawing?.pkDrawing {
            canvasView.drawing = drawing
        }
        self._canvasView = State(initialValue: canvasView)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                MapMapV(mapMap: mapMap, mapType: .fullImage)
                    .onViewResizes { self.mapMapSize = $1 }
                    .frame(
                        width: geo.size.width,
                        height: geo.size.height * 0.72
                    )
                DrawingView(canvasView: $canvasView)
                    .frame(
                        width: mapMapSize.width,
                        height: mapMapSize.height
                    )
                    .onAppear { self.setupToolPicker() }
                    .background(.blue.opacity(0.5))
                BottomDrawer(verticalDetents: [.content], horizontalDetents: [.left, .right], shortCardSize: 350) { _ in
                    HStack {
                        Button {
                            if let drawing = mapMap.drawing { drawing.drawingData = canvasView.drawing.dataRepresentation() }
                            else { _ = Drawing(context: moc, mapMap: mapMap, drawingData: canvasView.drawing.dataRepresentation()) }
                            dismiss()
                        } label: {
                            Text("Done")
                                .bigButton(backgroundColor: .blue)
                        }
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                                .bigButton(backgroundColor: .gray)
                        }
                        Button {
                            mapMap.drawing = nil
                            dismiss()
                        } label: {
                            Text("Delete")
                                .bigButton(backgroundColor: .red)
                        }
                    }
                }
            }
        }
    }
    
    private func setupToolPicker() {
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        toolPicker.isRulerActive = true
        canvasView.becomeFirstResponder()
        toolPicker.addObserver(canvasView)
    }
}
