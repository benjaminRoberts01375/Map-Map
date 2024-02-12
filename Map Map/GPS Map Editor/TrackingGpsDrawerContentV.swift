//
//  TrackingGpsDrawerContentV.swift
//  Map Map
//
//  Created by Ben Roberts on 2/9/24.
//

import SwiftUI

struct TrackingGpsDrawerContentV: View {
    /// Current GPS Map being edited.
    @ObservedObject var gpsMap: GPSMap
    /// Fire a timer notification every 0.25 seconds.
    @State var timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    /// Seconds since this view has been open.
    @State var additionalSeconds: TimeInterval = .zero
    /// GPS user location.
    @State private var locationsHandler = LocationsHandler.shared
    /// Current information about the base map.
    @Environment(MapDetailsM.self) var mapDetails
    
    var body: some View {
        VStack {
            HStack {
                let totalSeconds: TimeInterval = additionalSeconds + Double(gpsMap.durationSeconds)
                Text(totalSeconds.description)
                    .font(.title)
                    .fontWidth(.condensed)
                Spacer()
                Text("Done")
                    .font(.title)
            }
            HStack {
                Text(LocationDisplayMode.metersToString(meters: Double(gpsMap.distance)))
                    .foregroundStyle(.secondary)
                    .fontWidth(.condensed)
                Spacer()
                Text("max u ### max d ###")
                    .foregroundStyle(.secondary)
                    .fontWidth(.condensed)
            }
        }
        .padding(.horizontal, 10)
        .onReceive(timer) { _ in
            let startDate: Date
            if let trackingStartDate = gpsMap.trackingStartDate { startDate = trackingStartDate }
            else {
                let date = Date()
                gpsMap.trackingStartDate = date
                startDate = date
            }
            additionalSeconds = Date().timeIntervalSince(startDate)
        }
        .onChange(of: locationsHandler.lastLocation) { _, update in
            _ = gpsMap.addNewCoordinate(clLocation: update)
        }
        .onAppear { mapDetails.followUser() }
    }
}
