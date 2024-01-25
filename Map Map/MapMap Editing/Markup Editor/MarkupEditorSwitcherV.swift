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
        if let drawing = mapMap.drawing {
            if let pkDrawing = drawing.pkDrawing { canvasView.drawing = pkDrawing }
            self.mapMapSize = CGSize(width: drawing.mapMapWidth, height: drawing.mapMapHeight)
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
                        if let drawing = mapMap.drawing { moc.delete(drawing) }
                        dismiss()
                    } label: {
                        Text("Delete")
                            .bigButton(backgroundColor: .red)
                    }
                }
            }
        }
        .onAppear { setupToolPicker() }
        .onDisappear { mapMap.drawing?.mapMapSize = mapMapSize }
    }
    
    private func setupToolPicker() {
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        toolPicker.isRulerActive = true
        canvasView.becomeFirstResponder()
        toolPicker.addObserver(canvasView)
    }
}
