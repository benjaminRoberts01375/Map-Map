//
//  Crosshair.swift
//  Map Map
//
//  Created by Ben Roberts on 11/19/23.
//

import SwiftUI

struct CrosshairV: View {
    let spacing: CGFloat = 15
    
    var body: some View {
        ZStack {
            VStack(spacing: spacing) {
                CrosshairComponentV()
                CrosshairComponentV()
            }
            VStack(spacing: spacing) {
                CrosshairComponentV()
                CrosshairComponentV()
            }
            .rotationEffect(Angle(degrees: 90))
        }
    }
}

fileprivate struct CrosshairComponentV: View {
    var body: some View {
        Color.gray
            .frame(width: 3, height: 20)
            .clipShape(Capsule())
    }
}

#Preview {
    CrosshairV()
}
