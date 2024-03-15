//
//  GPSTrackingStatsV.swift
//  GPSTrackingLAExtension
//
//  Created by Ben Roberts on 3/15/24.
//

import SwiftUI

struct GPSTrackingStatsV: View {
    let distance: Double
    let speed: Measurement<UnitSpeed>
    let highPoint: Double
    let lowPoint: Double
    
    var body: some View {
        HStack {
            Spacer()
            Text(LocationDisplayMode.metersToString(meters: distance))
            Spacer()
            Text("\(LocationDisplayMode.speedToString(speed: speed))")
            Spacer()
            Text("\(LocationDisplayMode.metersToString(meters: highPoint)) ↑")
            Spacer()
            Text("\(LocationDisplayMode.metersToString(meters: lowPoint)) ↓")
            Spacer()
        }
        .foregroundStyle(.gray)
        .fontWidth(.condensed)
    }
}
