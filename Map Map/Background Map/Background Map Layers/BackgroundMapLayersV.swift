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
    @State var screenSpaceUserLocation: CGPoint?
    @State var screenSpaceMapMapLocations: [MapMap : CGRect] = [:]
    @State var screenSpaceMarkerLocations: [Marker : CGPoint] = [:]
    @Binding var displayType: LocationDisplayMode
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .center) {
                BackgroundMap(screenSpaceUserLocation: $screenSpaceUserLocation, screenSpaceMapMapLocations: $screenSpaceMapMapLocations, screenSpaceMarkerLocations: $screenSpaceMarkerLocations, mapScope: mapScope)
                BackgroundMapPointsV(screenSpaceUserLocation: $screenSpaceUserLocation, screenSpaceMarkerLocations: $screenSpaceMarkerLocations, screenSpaceMapMapLocations: $screenSpaceMapMapLocations, screenSize: geo.size)
                    .safeAreaPadding(geo.safeAreaInsets)
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
                        markerPositions: $screenSpaceMarkerLocations,
                        displayType: $displayType, screenSize: CGSize(
                            width: geo.size.width + geo.safeAreaInsets.leading + geo.safeAreaInsets.trailing,
                            height: geo.size.height + geo.safeAreaInsets.top + geo.safeAreaInsets.bottom
                        ),
                        mapScope: mapScope
                    )
                    .padding(.trailing, 8)
                    .background {
                        BlurView()
                            .blur(radius: blurAmount)
                            .ignoresSafeArea()
                            .allowsHitTesting(false)
                    }
                    Color.clear
                }
                .safeAreaPadding(geo.safeAreaInsets)
            }
            .ignoresSafeArea()
        }
        .mapScope(mapScope)
    }
}
