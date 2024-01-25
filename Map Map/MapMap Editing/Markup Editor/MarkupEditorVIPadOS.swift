//
//  MarkupEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 1/21/24.
//

import Bottom_Drawer
import PencilKit
import SwiftUI

struct MarkupEditorVIPadOS: View {
    /// MapMap's drawing being edited.
    @ObservedObject var mapMap: FetchedResults<MapMap>.Element
    /// Canvas to draw on.
    @Binding var canvasView: PKCanvasView
    /// Size of MapMap.
    @Binding var mapMapSize: CGSize
    
    var body: some View {
        ZStack(alignment: .center) {
            MapMapV(mapMap: mapMap, mapType: .fullImage)
                .onViewResizes { self.mapMapSize = $1 }
                .overlay {
                    DrawingView(canvasView: $canvasView)
                        .background(.blue.opacity(0.5))
                }
        }
    }
}
