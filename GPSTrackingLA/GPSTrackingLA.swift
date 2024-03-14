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
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GPSTrackingAttributes.self) { context in
            GPSTrackingLSLAV(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    EmptyView()
                }
            } compactLeading: {
                EmptyView()
            } compactTrailing: {
                EmptyView()
            } minimal: {
                EmptyView()
            }
        }
    }
}
