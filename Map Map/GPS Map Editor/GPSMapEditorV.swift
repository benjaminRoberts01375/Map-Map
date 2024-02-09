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
                        HStack {
                            TextField("GPS Map Name", text: $workingName)
                                .padding(.all, 5)
                                .background(Color.gray.opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .frame(width: 205)
                        }
                        HStack {
                            Button { moc.reset() } label: { Text("Cancel").bigButton(backgroundColor: .gray) }
                        }
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
