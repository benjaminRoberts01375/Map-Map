//
//  PhotoEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/31/23.
//

import Bottom_Drawer
import SwiftUI

struct PhotoEditorV: View {
    @ObservedObject var mapMap: FetchedResults<MapMap>.Element
    @State var topLeadingPoint: CGSize = .zero
    @State var topTrailingPoint: CGSize = .zero
    @State var bottomLeadingPoint: CGSize = .zero
    @State var bottomTrailingPoint: CGSize = .zero
    @State var screenSpaceImageSize: CGSize = .zero
    let pointsNeedSetup: Bool
    
    init(mapMap: FetchedResults<MapMap>.Element) {
        self.mapMap = mapMap
        if let corners = mapMap.cropCorners { // If there are pre-defined corners, set those up
            topLeadingPoint = corners.topLeading
            topTrailingPoint = corners.topTrailing
            bottomLeadingPoint = corners.bottomLeading
            bottomTrailingPoint = corners.bottomTrailing
            pointsNeedSetup = false
        }
        else { pointsNeedSetup = true }
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .center) {
                AnyView(mapMap.getMap(.fullImage))
                    .background {
                        GeometryReader { imageGeo in
                            Color.clear
                                .onChange(of: imageGeo.size, initial: true) { _, update in
                                    screenSpaceImageSize = update
                                    if pointsNeedSetup {
                                        topLeadingPoint = CGSize(width: -update.width / 2, height: -update.height / 2)
                                        topTrailingPoint = CGSize(width: update.width / 2, height: -update.height / 2)
                                        bottomLeadingPoint = CGSize(width: -update.width / 2, height: update.height / 2)
                                        bottomTrailingPoint = CGSize(width: update.width / 2, height: update.height / 2)
                                    }
                                }
                        }
                    }
                    .frame(height: geo.size.height * 0.75)
                    .overlay {
                        ZStack {
                            HandleV(position: $topLeadingPoint)
                            HandleV(position: $topTrailingPoint)
                            HandleV(position: $bottomLeadingPoint)
                            HandleV(position: $bottomTrailingPoint)
                        }
                    }
                    .position(x: geo.frame(in: .local).midX, y: geo.frame(in: .local).midY)
            }
        }
        .ignoresSafeArea()
        
//        BottomDrawer(verticalDetents: [.content], horizontalDetents: [.center], shortCardSize: 350) { _ in
//            
//        }
    }
}
