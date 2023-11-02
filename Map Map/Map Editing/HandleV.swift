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
    
    var body: some View {
        Circle()
            .frame(width: handleSize, height: handleSize)
            .foregroundStyle(.white)
            .offset(position)
    }
}
