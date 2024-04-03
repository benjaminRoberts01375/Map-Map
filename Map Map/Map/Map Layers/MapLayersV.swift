//
//  MapLayersV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/17/23.
//

import MapKit
import SwiftUI

/// Handles all layering related to the map being plotted on, including the map.
struct MapLayersV: View {
    /// Amount of blur to use with an effect blur.
    static let blurAmount: CGFloat = 10
    /// mapScope for syncing map buttons.
    @Namespace private var mapScope
    /// Details about the map.
    @Environment(MapDetailsM.self) private var mapDetails
    /// Timer for tracking crosshair overlay.
    @State private var timer: Timer?
    /// Current opacity of the crosshair.
    @State private var crosshairOpacity: Double = 0
    /// Current editor being used.
    @Binding var editor: Editor
    /// The minimum distance between the edge of the device and a UI element
    static var minSafeAreaDistance: CGFloat = 8
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .center) {
                MapV(editor: $editor, mapScope: mapScope)
                MapPointsV(
                    screenSize: CGSize(
                        width: geo.size.width + geo.safeAreaInsets.leading + geo.safeAreaInsets.trailing,
                        height: geo.size.height + geo.safeAreaInsets.top + geo.safeAreaInsets.bottom
                    ),
                    editor: $editor
                )
                BlurView()
                    .frame(width: geo.size.width, height: geo.safeAreaInsets.top)
                    .blur(radius: MapLayersV.blurAmount)
                    .allowsHitTesting(false)
                    .position(y: 0)
                CrosshairV()
                    .allowsHitTesting(false)
                    .opacity(crosshairOpacity)
                    .onChange(of: mapDetails.region.center) {
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
                    MapButtonsV(
                        editor: $editor,
                        screenSize: CGSize(
                            width: geo.size.width + geo.safeAreaInsets.leading + geo.safeAreaInsets.trailing,
                            height: geo.size.height + geo.safeAreaInsets.top + geo.safeAreaInsets.bottom
                        ),
                        mapScope: mapScope
                    )
                    .padding(.trailing, max(MapLayersV.minSafeAreaDistance, geo.safeAreaInsets.trailing))
                    .padding(.top, max(MapLayersV.minSafeAreaDistance, geo.safeAreaInsets.top))
                    .ignoresSafeArea()
                    Color.clear
                }
            }
            .ignoresSafeArea()
        }
        .mapScope(mapScope)
    }
}
