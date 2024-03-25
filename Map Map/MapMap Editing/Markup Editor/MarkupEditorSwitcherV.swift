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
    /// Current Core Data managed object context.
    @Environment(\.managedObjectContext) var moc
    /// Dismiss function for the view.
    @Environment(\.dismiss) var dismiss
    /// MapMap being drawn on.
    @ObservedObject var mapMap: FetchedResults<MapMap>.Element
    /// PKCanvas view to handle drawing.
    @State private var canvasView: PKCanvasView = PKCanvasView()
    /// Container for Markup toolbar.
    @State private var toolPicker = PKToolPicker()
    /// Displayed size of the map map.
    @State private var mapMapSize: CGSize = .zero
    /// Drawer height before getting tugged on.
    static let phoneDrawerHeight: CGFloat = 190
    /// Track if the device is a phone.
    private let isPhone: Bool
    
    init(mapMap: FetchedResults<MapMap>.Element) {
        self.mapMap = mapMap
        self.isPhone = UIDevice.current.userInterfaceIdiom == .phone
        if let drawing = mapMap.activeImage?.drawing {
            if let pkDrawing = drawing.pkDrawing { canvasView.drawing = pkDrawing }
            self.mapMapSize = CGSize(width: drawing.width, height: drawing.height)
        }
    }
    
    var body: some View {
        ZStack {
            if isPhone { MarkupEditorVIOS(mapMap: mapMap, canvasView: $canvasView, mapMapSize: $mapMapSize) }
            else { MarkupEditorVIPadOS(mapMap: mapMap, canvasView: $canvasView, mapMapSize: $mapMapSize) }
            BottomDrawer(
                verticalDetents: [self.isPhone ? .exactly(MarkupEditorSwitcherV.phoneDrawerHeight) : .content],
                horizontalDetents: [.left, .right],
                shortCardSize: 350
            ) { _ in
                HStack {
                    Button {
                        if let drawing = mapMap.activeImage?.drawing { drawing.drawingData = canvasView.drawing.dataRepresentation() }
                        else if let mapMapImage = mapMap.activeImage {
                            _ = MapMapImageDrawing(
                                context: moc,
                                mapMapImage: mapMapImage,
                                drawingData: canvasView.drawing.dataRepresentation()
                            )
                        }
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
                        if let drawing = mapMap.activeImage?.drawing { moc.delete(drawing) }
                        dismiss()
                    } label: {
                        Text("Delete")
                            .bigButton(backgroundColor: .red)
                    }
                }
            }
        }
        .onAppear { setupToolPicker() }
        .onDisappear {
            guard let mapImage = mapMap.activeImage,
                  let drawing = mapImage.drawing else { return }
            if let pkDrawing = drawing.pkDrawing, pkDrawing.strokes.isEmpty {
                moc.delete(drawing)
            }
            mapImage.drawing?.size = mapMapSize
        }
    }
    
    /// Configure Pencil Kit tool picker.
    private func setupToolPicker() {
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        toolPicker.isRulerActive = false
        canvasView.becomeFirstResponder()
        toolPicker.addObserver(canvasView)
    }
}
