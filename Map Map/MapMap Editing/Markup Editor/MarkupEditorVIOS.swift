//
//  MarkupEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 1/20/24.
//

import Bottom_Drawer
import PencilKit
import SwiftUI

/// Markup editor for iOS devices.
/// This view adds more spacing and control to work around the bottom drawer being fixed.
struct MarkupEditorVIOS: View {
    /// Undo manager.
    @Environment(\.undoManager) var undoer
    /// MapMap's drawing being edited.
    @ObservedObject var mapMap: FetchedResults<MapMap>.Element
    /// Canvas to draw on.
    @Binding var canvasView: PKCanvasView
    /// Size of MapMap.
    @Binding var mapMapSize: CGSize
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    undoer?.undo()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(.all, 10)
                        .accessibilityLabel("Undo")
                }
                Button {
                    undoer?.redo()
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
                        MapMapV(mapMap, imageType: .image)
                            .onViewResizes { mapMapSize = $1 }
                            .overlay { DrawingView(canvasView: $canvasView) }
                    }
                    Color.clear
                        .frame(height: MarkupEditorSwitcherV.phoneDrawerHeight)
                }
            }
        }
    }
}
