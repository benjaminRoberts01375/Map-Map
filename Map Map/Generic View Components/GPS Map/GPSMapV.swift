//
//  GPSMapV.swift
//  Map Map
//
//  Created by Ben Roberts on 2/16/24.
//

import MapKit
import SwiftUI

struct GPSMapV: View {
    /// Info about the base map.
    @Environment(MapDetailsM.self) var mapDetails
    /// GPS Map to view.
    @ObservedObject var gpsMap: GPSMap
    
    var body: some View {
        ZStack {
            ForEach(gpsMap.unwrappedBranches) { branch in
                GPSMapBranchV(gpsMapBranch: branch)
            }
        }
    }
}
