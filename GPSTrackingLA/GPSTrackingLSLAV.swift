//
//  GPSTrackingLSLAV.swift
//  Map Map
//
//  Created by Ben Roberts on 3/14/24.
//

import SwiftUI
import WidgetKit

struct GPSTrackingLSLAV: View {
    /// Current color scheme (dark vs light) of the system.
    @Environment(\.colorScheme) var colorScheme
    /// Context of the current Activity View, supplying state.
    let context: ActivityViewContext<GPSTrackingAttributes>
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text(context.state.seconds.description)
                    .font(.system(size: 35))
                    .fontWidth(.condensed)
                    .bigButton(backgroundColor: .gray, minWidth: 120)
                Spacer(minLength: 0)
                VStack(alignment: .trailing) {
                    Text(context.attributes.gpsMapName)
                        .font(.system(size: 25))
                        .fontWidth(.condensed)
                        .bold()
                        .lineLimit(1)
                    switch context.state.positionNotation {
                    case .degrees:
                        HStack {
                            Spacer(minLength: 0)
                            Text(context.state.positionNotation.degreesToString(latitude: context.state.userLatitude))
                            Text(context.state.positionNotation.degreesToString(longitude: context.state.userLongitude))
                        }
                        .font(.system(size: 20))
                        .fontWidth(.condensed)
                    case .DMS:
                        VStack(alignment: .trailing) {
                            Text(context.state.positionNotation.degreesToString(latitude: context.state.userLatitude))
                            Text(context.state.positionNotation.degreesToString(longitude: context.state.userLongitude))
                        }
                        .font(.system(size: 20))
                        .fontWidth(.condensed)
                    }
                }
            }
            .padding()
            GPSTrackingStatsV(
                distance: Double(context.state.distance),
                speed: (context.state.speed),
                highPoint: Double(context.state.highPoint),
                lowPoint: Double(context.state.lowPoint)
            )
            .background(colorScheme == .dark ? .mapMapSecondary : .white)
        }
        .background(
            LinearGradient(
                colors: [.clear, colorScheme == .dark ? .black.opacity(0.5) : .clear],
                startPoint: UnitPoint(
                    x: UnitPoint.center.x / 2,
                    y: UnitPoint.center.y
                ),
                endPoint: .trailing
            )
        )
        .background(colorScheme == .dark ? Color(red: 0.27, green: 0.45, blue: 0.28) : Color(red: 0.65, green: 0.82, blue: 0.48))
    }
}
