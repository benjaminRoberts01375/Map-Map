//
//  GPSMapEditingPhaseControllerV.swift
//  Map Map
//
//  Created by Ben Roberts on 2/21/24.
//

import SwiftUI

struct GPSMapEditingPhaseControllerV: View {
    @State private var mode: EditingMode = .editing
    @ObservedObject var gpsMap: GPSMap
    
    enum EditingMode {
        case editing
        case painting
    }
    
    var body: some View {
        switch mode {
        case .editing:
            GPSMapEditingV(gpsMap, editingMode: $mode)
        case .painting:
            EmptyView()
        }
    }
}
