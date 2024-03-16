//
//  TrackingGpsDrawerContentV.swift
//  Map Map
//
//  Created by Ben Roberts on 2/9/24.
//

import ActivityKit
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
    /// Track the position of the stats.
    @State var statsBottom: Bool = true
    /// ID for the current live activity if one is running.
    @State var activityID: String?
    /// How to display coordinates on screen.
    @AppStorage(UserDefaults.kCoordinateDisplayType) var locationDisplayType = UserDefaults.dCoordinateDisplayType
    
    var body: some View {
        VStack {
            HStack {
                let totalSeconds: TimeInterval = Double(additionalSeconds + Int(gpsMap.durationSeconds))
                Text(totalSeconds.description)
                    .font(.system(size: 35))
                    .fontWidth(.condensed)
                    .bigButton(backgroundColor: .gray, minWidth: 120)
                Spacer(minLength: 0)
                    .onViewResizes { _, new in
                        statsBottom = new.width < 120
                    }
                    .overlay {
                        if !statsBottom {
                            HStack {
                                VStack(alignment: .trailing) {
                                    Text("\(LocationDisplayMode.metersToString(meters: Double(gpsMap.heightMax))) ↑")
                                    Text("\(LocationDisplayMode.metersToString(meters: Double(gpsMap.heightMin))) ↓")
                                }
                                VStack(alignment: .leading) {
                                    Text(LocationDisplayMode.metersToString(meters: Double(gpsMap.distance)))
                                    Text("\(LocationDisplayMode.speedToString(speed: speed))")
                                }
                            }
                            .foregroundStyle(.secondary)
                            .fontWidth(.condensed)
                            .transition(.opacity)
                        }
                    }
                Button {
                    if showDoneConfirmation {
                        gpsMap.durationSeconds += Int32(additionalSeconds)
                        gpsMap.isTracking = false
                        guard let moc = gpsMap.managedObjectContext
                        else { return }
                        try? moc.save()
                        endLiveActivity()
                    }
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
            if statsBottom {
                HStack {
                    Text(LocationDisplayMode.metersToString(meters: Double(gpsMap.distance)))
                    Text("\(LocationDisplayMode.speedToString(speed: speed))")
                    Text("\(LocationDisplayMode.metersToString(meters: Double(gpsMap.heightMax))) ↑")
                    Text("\(LocationDisplayMode.metersToString(meters: Double(gpsMap.heightMin))) ↓")
                }
                .foregroundStyle(.secondary)
                .fontWidth(.condensed)
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showDoneConfirmation)
        .animation(.easeInOut(duration: 0.25), value: statsBottom)
        .onReceive(timer) { _ in
            let startDate: Date
            if let trackingStartDate = gpsMap.trackingStartDate { startDate = trackingStartDate }
            else {
                let date = Date()
                gpsMap.trackingStartDate = date
                startDate = date
            }
            let newTime = Int(Date().timeIntervalSince(startDate))
            if additionalSeconds == newTime { return }
            self.additionalSeconds = newTime
            updateLiveActivity()
        }
        .onChange(of: locationsHandler.lastLocation) { _ = gpsMap.addNewCoordinate(clLocation: $1) }
        .onChange(of: additionalSeconds) {
            let totalSeconds: TimeInterval = Double(additionalSeconds + Int(gpsMap.durationSeconds))
            self.speed = Measurement(value: Double(gpsMap.distance) / totalSeconds, unit: .metersPerSecond)
        }
        .onAppear { mapDetails.followUser() }
        .onAppear { setupLiveActivity() }
    }
    
    private func setupLiveActivity() {
        locationsHandler.startAlwaysLocation()
        let attributes = GPSTrackingAttributes(gpsMapName: gpsMap.name ?? "New GPS Map")
        let initialContentState = ActivityContent(
            state: GPSTrackingAttributes.ContentState(
                userLongitude: locationsHandler.lastLocation.coordinate.longitude,
                userLatitude: locationsHandler.lastLocation.coordinate.latitude,
                seconds: Double(additionalSeconds + Int(gpsMap.durationSeconds)),
                speed: speed,
                highPoint: gpsMap.heightMax,
                lowPoint: gpsMap.heightMin,
                distance: gpsMap.distance, 
                positionNotation: locationDisplayType
            ),
            staleDate: .now + 5
        )
        guard let activity = try? Activity.request(
            attributes: attributes,
            content: initialContentState,
            pushType: .none
        )
        else { return }
        self.activityID = activity.id
    }
    
    private func updateLiveActivity() {
        guard let activityID = activityID,
              let activity = Activity<GPSTrackingAttributes>.activities.first(where: { $0.id == activityID })
        else { return }
        let newContentState = GPSTrackingAttributes.ContentState(
            userLongitude: locationsHandler.lastLocation.coordinate.longitude,
            userLatitude: locationsHandler.lastLocation.coordinate.latitude,
            seconds: Double(additionalSeconds + Int(gpsMap.durationSeconds)),
            speed: speed,
            highPoint: gpsMap.heightMax,
            lowPoint: gpsMap.heightMin,
            distance: gpsMap.distance,
            positionNotation: locationDisplayType
        )
        let activityContent = ActivityContent(state: newContentState, staleDate: .now + 5)
        Task { await activity.update(activityContent) }
    }
    
    private func endLiveActivity() {
        guard let activityID = activityID,
              let runningActiivty = Activity<GPSTrackingAttributes>.activities.first(where: { $0.id == activityID })
        else { return }
        locationsHandler.endAlwaysLocation()
        let newContentState = GPSTrackingAttributes.ContentState(
            userLongitude: locationsHandler.lastLocation.coordinate.longitude,
            userLatitude: locationsHandler.lastLocation.coordinate.latitude,
            seconds: Double(additionalSeconds + Int(gpsMap.durationSeconds)),
            speed: speed,
            highPoint: gpsMap.heightMax,
            lowPoint: gpsMap.heightMin,
            distance: gpsMap.distance,
            positionNotation: locationDisplayType
        )
        let activityContent = ActivityContent(state: newContentState, staleDate: .now + 5)
        Task { await runningActiivty.end(activityContent, dismissalPolicy: .immediate)
            DispatchQueue.main.async {
                self.activityID = nil
            }
        }
    }
}
