//
//  GPSTrackingLSLAV.swift
//  Map Map
//
//  Created by Ben Roberts on 3/14/24.
//

import SwiftUI
import WidgetKit

struct GPSTrackingLSLAV: View {
    @Environment(\.colorScheme) var colorScheme
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
            .padding()
            HStack {
                Spacer()
                Text(LocationDisplayMode.metersToString(meters: Double(context.state.distance)))
                Spacer()
                Text("\(LocationDisplayMode.speedToString(speed: context.state.speed))")
                Spacer()
                Text("\(LocationDisplayMode.metersToString(meters: Double(context.state.highPoint))) ↑")
                Spacer()
                Text("\(LocationDisplayMode.metersToString(meters: Double(context.state.lowPoint))) ↓")
                Spacer()
            }
            .foregroundStyle(.secondary)
            .fontWidth(.condensed)
            .background(colorScheme == .dark ? .black : .white)
        }
        .background(colorScheme == .dark ? Color(red: 0.33, green: 0.45, blue: 0.28) : Color(red: 0.65, green: 0.82, blue: 0.48))
    }
}
