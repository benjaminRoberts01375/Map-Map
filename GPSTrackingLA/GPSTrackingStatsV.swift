//
//  GPSTrackingStatsV.swift
//  GPSTrackingLAExtension
//
//  Created by Ben Roberts on 3/15/24.
//

import SwiftUI

struct GPSTrackingStatsV: View {
    /// Distance the user has traveled during this GPS Map.
    let distance: Double
    /// Current speed of the user.
    let speed: Measurement<UnitSpeed>
    /// Highest point in the GPS Map.
    let highPoint: Double
    /// Lowest point in the GPS Map.
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
