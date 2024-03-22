//
//  GPSTrackingLA.swift
//  GPSTrackingLA
//
//  Created by Ben Roberts on 3/12/24.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct GPSTrackingLA: Widget { // View controller
    /// Amount of padding for live activity in Dynamic Island.
    let paddingDistance: CGFloat = 7
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GPSTrackingAttributes.self) { context in
            GPSTrackingLSLAV(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    VStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(.white)
                        GPSTrackingStatsV(
                            distance: Double(context.state.distance),
                            speed: (context.state.speed),
                            highPoint: Double(context.state.highPoint),
                            lowPoint: Double(context.state.lowPoint)
                        )
                    }
                }
                DynamicIslandExpandedRegion(.center) {
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
                                .foregroundStyle(Color.accentColor)
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
                                HStack {
                                    Spacer(minLength: 0)
                                    Text(context.state.positionNotation.degreesToString(latitude: context.state.userLatitude))
                                    Text(context.state.positionNotation.degreesToString(longitude: context.state.userLongitude))
                                }
                                .font(.system(size: 17))
                                .fontWidth(.condensed)
                            }
                        }
                    }
                }
                
            } compactLeading: {
                Text(LocationDisplayMode.metersToString(meters: Double(context.state.distance)))
                    .foregroundStyle(Color.accentColor)
                    .padding(paddingDistance)
            } compactTrailing: {
                Text(LocationDisplayMode.speedToString(speed: context.state.speed))
                    .foregroundStyle(Color.accentColor)
                    .padding(paddingDistance)
            } minimal: {
                Image(systemName: "map.fill")
                    .foregroundStyle(Color.accentColor)
                    .padding(paddingDistance)
            }
        }
    }
}
