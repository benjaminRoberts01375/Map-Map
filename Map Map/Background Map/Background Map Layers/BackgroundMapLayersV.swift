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
    @EnvironmentObject var backgroundMapDetails: BackgroundMapDetailsM
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .center) {
                BackgroundMap(mapScope: mapScope)
                    .ignoresSafeArea()
                BlurView()
                    .frame(width: geo.size.width, height: geo.safeAreaInsets.top)
                    .blur(radius: blurAmount)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .position(y: 0)
                CrosshairV()
                    }
                VStack(alignment: .trailing) {
                    BackgroundMapButtonsV(mapScope: mapScope)
                        .padding(.trailing, 8)
                        .background {
                            BlurView()
                                .blur(radius: blurAmount)
                                .ignoresSafeArea()
                                .allowsHitTesting(false)
                        }
                    Color.clear
                }
            }
        }
        .mapScope(mapScope)
    }
}
