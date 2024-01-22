//
//  MarkupEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 1/20/24.
//

import Bottom_Drawer
import PencilKit
import SwiftUI

struct MarkupEditorVIOS: View {
    @ObservedObject var mapMap: FetchedResults<MapMap>.Element
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @State private var canvasView: PKCanvasView
    @State private var toolPicker = PKToolPicker()
    @State private var mapMapSize: CGSize = .zero
    
    static let phoneDrawerHeight: CGFloat = 190
    
    init(mapMap: FetchedResults<MapMap>.Element) {
        self.mapMap = mapMap
        let canvasView = PKCanvasView()
        if let drawing = mapMap.drawing?.pkDrawing {
            canvasView.drawing = drawing
        }
        self._canvasView = State(initialValue: canvasView)
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(.all, 10)
                        .accessibilityLabel("Undo")
                }
                Button {
                    
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(.all, 10)
                        .accessibilityLabel("Redo")
                }
            }
            .padding(.trailing)
            ZStack {
                Color.clear
                VStack {
                    ZStack {
                        MapMapV(mapMap: mapMap, mapType: .fullImage)
                            .overlay {
                                DrawingView(canvasView: $canvasView)
                                    .onAppear { self.setupToolPicker() }
                                    .background(.blue.opacity(0.5))
                            }
                    }
                    Color.clear
                        .frame(height: MarkupEditorV.phoneDrawerHeight)
                }
                BottomDrawer(
                    verticalDetents: [UIDevice.current.userInterfaceIdiom == .pad ? .content : .exactly(MarkupEditorV.phoneDrawerHeight)],
                    horizontalDetents: [.left, .right],
                    shortCardSize: 350
                ) { _ in
                    VStack {
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
    }
    
    private func setupToolPicker() {
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        toolPicker.isRulerActive = true
        canvasView.becomeFirstResponder()
        toolPicker.addObserver(canvasView)
    }
}
