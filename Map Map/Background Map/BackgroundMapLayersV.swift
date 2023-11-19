//
//  BackgroundMapLayersV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/17/23.
//

import SwiftUI

struct BackgroundMapLayersV: View {
    let blurAmount: CGFloat = 10
    @Namespace var mapScope
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topTrailing) {
                BackgroundMap(mapScope: mapScope)
                    .ignoresSafeArea()
                BlurView()
                    .frame(width: geo.size.width, height: geo.safeAreaInsets.top)
                    .blur(radius: blurAmount)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
//                BackgroundMapHudV(mapNameSpace: mapNameSpace)
//                    .ignoresSafeArea()
//                    .padding(.trailing, 80)
//                    .offset(y: -30)
            }
        }
        .mapScope(mapScope)
    }
}
