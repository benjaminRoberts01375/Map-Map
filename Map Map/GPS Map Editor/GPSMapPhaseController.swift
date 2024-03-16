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
    @State var editingMode: EditingMode
    
    init(gpsMap: GPSMap) {
        self.workingName = gpsMap.name ?? ""
        self.gpsMap = gpsMap
        self.editingMode = gpsMap.isSetup ? .editing : .settingUp
    }
    
    enum EditingMode {
        case settingUp
        case tracking
        case editing
        case editingBranch(GPSMapBranch)
        case selectingBranch
    }
    
    var body: some View {
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
                    case .editing: GPSMapEditingV(gpsMap, editingMode: $editingMode)
                    case .selectingBranch: GPSMapBranchesV(gpsMap: gpsMap, editingMode: $editingMode)
                    case .editingBranch(let branch): GPSMapBranchEditingV(gpsMapBranch: branch, editingMode: $editingMode)
                    }
                }
                .padding(.bottom, isShortCard ? 0 : 10)
                .padding(.horizontal, 15)
            }
        }
        .onAppear { mapDetails.preventFollowingUser() }
        .onChange(of: gpsMap.isTracking) { editingMode = $1 ? .tracking : .editing }
    }
}
