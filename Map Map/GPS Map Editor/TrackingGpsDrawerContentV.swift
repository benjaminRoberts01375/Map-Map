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
    
    var body: some View {
        HStack {
            let totalSeconds: TimeInterval = additionalSeconds + Double(gpsMap.durationSeconds)
            Text(totalSeconds.description)
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
            additionalSeconds = Date().timeIntervalSince(startDate)
        }
    }
}
