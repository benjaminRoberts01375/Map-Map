//
//  TrackingGpsDrawerContentV.swift
//  Map Map
//
//  Created by Ben Roberts on 2/9/24.
//

import SwiftUI

struct TrackingGpsDrawerContentV: View {
    @ObservedObject var gpsMap: GPSMap
    @State var timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    @State var additionalSeconds: TimeInterval = .zero
    /// GPS user location.
    @State private var locationsHandler = LocationsHandler.shared
    
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
    }
}
