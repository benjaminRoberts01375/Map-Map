//
//  GPSMapEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 2/9/24.
//

import Bottom_Drawer
import SwiftUI

struct GPSMapEditorV: View {
    /// The current managed object context.
    @Environment(\.managedObjectContext) var moc
    /// Current information about the base map.
    @Environment(MapDetailsM.self) var mapDetails
    /// Current name of the GPS Map
    @State var workingName: String
    
    @ObservedObject var gpsMap: FetchedResults<GPSMap>.Element
    
    init(gpsMap: GPSMap) {
        self.workingName = gpsMap.name ?? ""
        self.gpsMap = gpsMap
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                BottomDrawer(verticalDetents: [.content], horizontalDetents: [.center], shortCardSize: 350) { isShortCard in
                    VStack {
                        if let coordinates = gpsMap.coordinates, coordinates.count == .zero {
                            NewGPSDrawerContentV(workingName: $workingName, gpsMap: gpsMap)
                        }
                        else { EmptyView() }
                    }
                    .padding(.bottom, isShortCard ? 0 : 10)
                }
                .safeAreaPadding(geo.safeAreaInsets)
            }
            .ignoresSafeArea()
        }
        .onAppear { mapDetails.preventFollowingUser() }
    }
}
