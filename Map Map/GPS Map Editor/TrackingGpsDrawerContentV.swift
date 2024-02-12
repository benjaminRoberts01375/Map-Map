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
    
    var body: some View {
        HStack {
            let totalSeconds: TimeInterval = Double(additionalSeconds + Int(gpsMap.durationSeconds))
            Text(totalSeconds.description)
                .font(.system(size: 35))
                .fontWidth(.condensed)
                .bigButton(backgroundColor: .gray)
            Spacer()
            VStack(alignment: .trailing) {
                Text(LocationDisplayMode.metersToString(meters: Double(gpsMap.distance)))
                Text("\(LocationDisplayMode.speedToString(speed: speed))")
            }
            .foregroundStyle(.secondary)
            .fontWidth(.condensed)
            VStack(alignment: .leading) {
                Text("max u ###")
                Text("max d ###")
            }
            .foregroundStyle(.secondary)
            .fontWidth(.condensed)
            Button {
                print("Trigger confirmation")
            } label: {
                Text("Done")
                    .font(.title3)
                    .bigButton(backgroundColor: .red)
            }
        }
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
