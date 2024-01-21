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
    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var mapMapSize: CGSize = .zero
    
    var body: some View {
        ZStack {
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
                }
            }
            BottomDrawer(verticalDetents: [.exactly(180)], horizontalDetents: [.center]) { isShortCard in
                Text("Temp")
            }
        }
    }
    
    private func setupToolPicker() {
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        toolPicker.isRulerActive = true
        canvasView.becomeFirstResponder()
    }
}
