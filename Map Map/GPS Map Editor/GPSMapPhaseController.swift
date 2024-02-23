//
//  GPSMapEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 2/9/24.
//

import Bottom_Drawer
import SwiftUI

struct GPSMapPhaseController: View {
    /// The current managed object context.
    @Environment(\.managedObjectContext) var moc
    /// Current information about the base map.
    @Environment(MapDetailsM.self) var mapDetails
    /// Current name of the GPS Map
    @State var workingName: String
    /// GPS Map to edit.
    @ObservedObject var gpsMap: FetchedResults<GPSMap>.Element
    /// Track the current mode of editing.
    @State var editingMode: EditingMode = .viewing
    
    init(gpsMap: GPSMap) {
        self.workingName = gpsMap.name ?? ""
        self.gpsMap = gpsMap
        translateFromGPSEditingMode()
    }
    
    enum EditingMode {
        case settingUp
        case tracking
        case editing
        case painting
        case viewing
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                BottomDrawer(
                    verticalDetents: [.content],
                    horizontalDetents: [.center],
                    shortCardSize: UIDevice.current.userInterfaceIdiom == .pad ? 400 : 360
                ) { isShortCard in
                    VStack {
                        switch editingMode {
                        case .settingUp: NewGPSDrawerContentV(workingName: $workingName, gpsMap: gpsMap)
                        case .tracking: TrackingGpsDrawerContentV(gpsMap: gpsMap)
                        case .editing: GPSMapEditingV(gpsMap)
                        case .painting: EmptyView()
                        case .viewing: EmptyView()
                        }
                    }
                    .padding(.bottom, isShortCard ? 0 : 10)
                    .padding(.horizontal, 15)
                }
                .safeAreaPadding(geo.safeAreaInsets)
            }
            .ignoresSafeArea()
        }
        .onAppear { mapDetails.preventFollowingUser() }
        .onChange(of: gpsMap.unwrappedEditing) { translateFromGPSEditingMode() }
    }
    
    func translateFromGPSEditingMode() {
        switch gpsMap.unwrappedEditing {
        case .settingUp: self.editingMode = .settingUp
        case .tracking: self.editingMode = .tracking
        case .editing: self.editingMode = .editing
        case .viewing: self.editingMode = .viewing
        }
    }
}
