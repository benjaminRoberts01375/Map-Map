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
    @State var additionalSeconds: Int = .zero
    /// GPS user location.
    @State private var locationsHandler = LocationsHandler.shared
    /// Current information about the base map.
    @Environment(MapDetailsM.self) var mapDetails
    /// Current speed of the user
    @State var speed: Measurement<UnitSpeed> = Measurement(value: 0, unit: .metersPerSecond)
    /// Track showing the confirmation dialog for the done button
    @State var showDoneConfirmation: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                let totalSeconds: TimeInterval = Double(additionalSeconds + Int(gpsMap.durationSeconds)) + 3600 * 10
                Text(totalSeconds.description)
                    .font(.system(size: 35))
                    .fontWidth(.condensed)
                    .bigButton(backgroundColor: .gray, minWidth: 120)
                Spacer(minLength: 0)
                Button {
                    if showDoneConfirmation { showDoneConfirmation = false }
                    else { showDoneConfirmation = true }
                } label: {
                    Text("Done")
                        .font(.title3)
                        .bigButton(backgroundColor: .red)
                }
                if showDoneConfirmation {
                    Button {
                        showDoneConfirmation = false
                    } label: {
                        Text("Cancel")
                            .font(.title3)
                            .bigButton(backgroundColor: .green)
                    }
                    .transition(.offset(x: 110))
                }
            }
            HStack {
                Text(LocationDisplayMode.metersToString(meters: Double(gpsMap.distance)))
                Text("\(LocationDisplayMode.speedToString(speed: speed))")
                Text("500 ft ↑")
                Text("100 ft ↓")
            }
            .foregroundStyle(.secondary)
            .fontWidth(.condensed)
        }
        .animation(.easeInOut(duration: 0.25), value: showDoneConfirmation)
        .onReceive(timer) { _ in
            let startDate: Date
            if let trackingStartDate = gpsMap.trackingStartDate { startDate = trackingStartDate }
            else {
                let date = Date()
                gpsMap.trackingStartDate = date
                startDate = date
            }
            additionalSeconds = Int(Date().timeIntervalSince(startDate))
        }
        .onChange(of: locationsHandler.lastLocation) { _, update in
            _ = gpsMap.addNewCoordinate(clLocation: update)
        }
        .onChange(of: additionalSeconds) {
            let totalSeconds: TimeInterval = Double(additionalSeconds + Int(gpsMap.durationSeconds))
            self.speed = Measurement(value: Double(gpsMap.distance) / totalSeconds, unit: .metersPerSecond)
        }
        .onAppear { mapDetails.followUser() }
    }
}
