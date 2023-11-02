//
//  HandleV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/2/23.
//

import SwiftUI

struct HandleV: View {
    @Binding var position: CGSize
    @State var previousFrameDragAmount: CGSize = .zero
    let handleSize: CGFloat = 30
    
    var dragGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { update in
                position.width += update.translation.width - previousFrameDragAmount.width
                position.height += update.translation.height - previousFrameDragAmount.height
                previousFrameDragAmount = update.translation
            }
            .onEnded { _ in
                previousFrameDragAmount = .zero
            }
    }
    
    var body: some View {
        Circle()
            .frame(width: handleSize, height: handleSize)
            .foregroundStyle(.white)
            .offset(position)
            .gesture(dragGesture)
            .shadow(radius: 2)
    }
}
