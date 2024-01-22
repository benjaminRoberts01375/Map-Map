//
//  MarkupEditorSwitcher.swift
//  Map Map
//
//  Created by Ben Roberts on 1/21/24.
//

import Bottom_Drawer
import PencilKit
import SwiftUI

struct MarkupEditorSwitcherV: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @ObservedObject var mapMap: FetchedResults<MapMap>.Element
    @State private var canvasView: PKCanvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    static let phoneDrawerHeight: CGFloat = 190
    private let isPhone: Bool
    
    init(mapMap: FetchedResults<MapMap>.Element) {
        self.mapMap = mapMap
        self.isPhone = UIDevice.current.userInterfaceIdiom == .phone
        if let drawing = mapMap.drawing?.pkDrawing { canvasView.drawing = drawing }
    }
    
    var body: some View {
        ZStack {
            if isPhone { MarkupEditorVIOS(mapMap: mapMap, canvasView: $canvasView) }
            else { MarkupEditorVIPadOS(mapMap: mapMap, canvasView: $canvasView) }
            BottomDrawer(
                verticalDetents: [self.isPhone ? .exactly(MarkupEditorSwitcherV.phoneDrawerHeight) : .content],
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
        .onAppear { setupToolPicker() }
    }
    
    private func setupToolPicker() {
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        toolPicker.isRulerActive = true
        canvasView.becomeFirstResponder()
        toolPicker.addObserver(canvasView)
    }
}
