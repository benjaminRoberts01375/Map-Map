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
    @State var additionalSeconds: Int = 0
    
    var body: some View {
        HStack {
            let formattedText: String = {
                let totalSeconds = additionalSeconds + Int(gpsMap.durationSeconds)
                let hours = Int(totalSeconds / 3600)
                let minutes = Int((totalSeconds - hours * 3600) / 60)
                let seconds = Int(totalSeconds - (hours * 60 + minutes) * 60)
                var time: String = "\(minutes):\(seconds)"
                if hours != .zero { time = "\(hours):\(time)" }
                return time
            }()
            Text("\(formattedText)")
            VStack {
                
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
    }
}
