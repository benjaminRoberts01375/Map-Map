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
    @State var timer: Timer?
    @State var crosshairOpacity: Double = 0
    
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
                    .opacity(crosshairOpacity)
                    .onChange(of: backgroundMapDetails.position) {
                        if timer != nil {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                crosshairOpacity = 1
                            }
                        }
                        timer?.invalidate()
                        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                            withAnimation(.easeOut(duration: 0.5)) {
                                self.crosshairOpacity = 0
                            }
                        }
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
