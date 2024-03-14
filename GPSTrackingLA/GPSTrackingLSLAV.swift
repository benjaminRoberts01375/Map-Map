//
//  GPSTrackingLSLAV.swift
//  Map Map
//
//  Created by Ben Roberts on 3/14/24.
//

import WidgetKit
import SwiftUI

struct GPSTrackingLSLAV: View {
    let context: ActivityViewContext<GPSTrackingAttributes>

    var body: some View {
        VStack {
            HStack {
                Text(context.state.seconds.description)
                    .font(.system(size: 35))
                    .fontWidth(.condensed)
                    .bigButton(backgroundColor: .gray, minWidth: 120)
                Spacer(minLength: 0)
            }
            HStack {
                Text(LocationDisplayMode.metersToString(meters: Double(context.state.distance)))
                Text("\(LocationDisplayMode.speedToString(speed: context.state.speed))")
                Text("\(LocationDisplayMode.metersToString(meters: Double(context.state.highPoint))) ↑")
                Text("\(LocationDisplayMode.metersToString(meters: Double(context.state.lowPoint))) ↓")
            }
            .foregroundStyle(.secondary)
            .fontWidth(.condensed)
        }
    }
}
