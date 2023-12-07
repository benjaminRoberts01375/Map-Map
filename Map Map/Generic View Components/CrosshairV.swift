//
//  Crosshair.swift
//  Map Map
//
//  Created by Ben Roberts on 11/19/23.
//

import SwiftUI

/// Crosshair that changes color slightly based on what's under it.
struct CrosshairV: View {
    private let spacing: CGFloat = 15
    
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
    let size = CGSize(width: 4, height: 20)
    
    var body: some View {
        Rectangle()
            .fill(.white)
            .blendMode(.difference)
            .clipShape(Capsule())
            .frame(width: size.width, height: size.height)
            .overlay {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .light)
                    .clipShape(Capsule())
                    .frame(width: size.width, height: size.height)
            }
    }
}

#Preview {
    CrosshairV()
}
