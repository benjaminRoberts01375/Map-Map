//
//  BackgroundMapLayersV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/17/23.
//

import SwiftUI

/// Handles all layering related to the background map being plotted on, including the background map.
struct BackgroundMapLayersV: View {
    /// Amount of blur to use with an effect blur.
    private let blurAmount: CGFloat = 10
    /// mapScope for syncing background map buttons.
    @Namespace private var mapScope
    /// Details about the background map.
    @Environment(BackgroundMapDetailsM.self) private var backgroundMapDetails
    /// Timer for tracking crosshair overlay.
    @State private var timer: Timer?
    /// Current opacity of the crosshair.
    @State private var crosshairOpacity: Double = 0
    /// Coordinate display type.
    @Binding var displayType: LocationDisplayMode
    /// The minimum distance between the edge of the device and a UI element
    static var minSafeAreaDistance: CGFloat = 8
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .center) {
                BackgroundMap(mapScope: mapScope)
                BackgroundMapPointsV(
                    screenSize: CGSize(
                        width: geo.size.width + geo.safeAreaInsets.leading + geo.safeAreaInsets.trailing,
                        height: geo.size.height + geo.safeAreaInsets.top + geo.safeAreaInsets.bottom
                    )
                )
                BlurView()
                    .frame(width: geo.size.width, height: geo.safeAreaInsets.top)
                    .blur(radius: blurAmount)
                    .allowsHitTesting(false)
                    .position(y: 0)
                CrosshairV()
                    .allowsHitTesting(false)
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
                    BackgroundMapButtonsV(
                        displayType: $displayType,
                        screenSize: CGSize(
                            width: geo.size.width + geo.safeAreaInsets.leading + geo.safeAreaInsets.trailing,
                            height: geo.size.height + geo.safeAreaInsets.top + geo.safeAreaInsets.bottom
                        ),
                        mapScope: mapScope
                    )
                    .padding(.trailing, max(BackgroundMapLayersV.minSafeAreaDistance, geo.safeAreaInsets.trailing))
                    .padding(.top, max(BackgroundMapLayersV.minSafeAreaDistance, geo.safeAreaInsets.top))
                    .ignoresSafeArea()
                    .background {
                        BlurView()
                            .blur(radius: blurAmount)
                            .ignoresSafeArea()
                            .allowsHitTesting(false)
                    }
                    Color.clear
                }
            }
            .ignoresSafeArea()
        }
        .mapScope(mapScope)
    }
}
