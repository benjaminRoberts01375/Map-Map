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
    @Binding var canvasView: PKCanvasView
    
    static let phoneDrawerHeight: CGFloat = 190
    
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
                                    .background(.blue.opacity(0.5))
                            }
                    }
                    Color.clear
                        .frame(height: MarkupEditorSwitcherV.phoneDrawerHeight)
                }
            }
        }
    }
}
