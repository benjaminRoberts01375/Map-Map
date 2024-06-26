//
//  TrackingGpsDrawerContentV.swift
//  Map Map
//
//  Created by Ben Roberts on 2/9/24.
//

import ActivityKit
import SwiftUI

struct TrackingGpsDrawerContentV: View {
    /// Current information about the base map.
    @Environment(MapDetailsM.self) var mapDetails
    /// How to display coordinates on screen.
    @AppStorage(UserDefaults.kCoordinateDisplayType) var locationDisplayType = UserDefaults.dCoordinateDisplayType
    /// Current GPS Map being edited.
    @ObservedObject var gpsMap: GPSMap
    /// Fire a timer notification every 0.25 seconds.
    @State var timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    /// GPS user location.
    @State private var locationsHandler = LocationsHandler.shared
    /// Current speed of the user
    @State var speed: Measurement<UnitSpeed> = Measurement(value: 0, unit: .metersPerSecond)
    /// Track showing the confirmation dialog for the done button
    @State var showDoneConfirmation: Bool = false
    /// Track the position of the stats.
    @State var statsBottom: Bool = true
    /// ID for the current live activity if one is running.
    @State var activityID: String?
    /// Fill in gaps of time between connections being added.
    @State var continuousTimeTrack: Int = 0
    /// Base timestamp to use when displaying time.
    @State var timeReference: Date?
    
    var body: some View {
        VStack {
            HStack {
                Text(Double(continuousTimeTrack).description)
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
            timeKeep()
        }
        .onChange(of: locationsHandler.lastLocation, initial: true) { _ = gpsMap.addNewCoordinate(clLocation: $1) }
        .onChange(of: gpsMap.connections?.count) {
            if timeReference == nil { timeReference = gpsMap.unwrappedConnections.first?.start?.timestamp ?? .now }
            let proposedSpeed: Measurement<UnitSpeed> = Measurement(value: Double(gpsMap.distance) / (gpsMap.time), unit: .metersPerSecond)
            self.speed = proposedSpeed.value.isNormal ? proposedSpeed : Measurement<UnitSpeed>(value: 0, unit: .metersPerSecond)
        }
        .onAppear { mapDetails.followUser() }
        .onAppear { setupLiveActivity() }
        .onDisappear { gpsMap.isSetup = true }
    }
    
    /// Initialize a live activity with data.
    private func setupLiveActivity() {
        locationsHandler.startAlwaysLocation()
        let attributes = GPSTrackingAttributes(gpsMapName: gpsMap.name ?? "New GPS Map")
        let initialContentState = ActivityContent(
            state: GPSTrackingAttributes.ContentState(
                userLongitude: locationsHandler.lastLocation.coordinate.longitude,
                userLatitude: locationsHandler.lastLocation.coordinate.latitude,
                seconds: Double(continuousTimeTrack),
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
    
    private func timeKeep() {
        guard let timeReference = timeReference else { return }
        let newTime: Int = Int(abs(timeReference.timeIntervalSinceNow))
        if newTime != self.continuousTimeTrack {
            self.continuousTimeTrack = newTime
            updateLiveActivity()
        }
    }
    
    /// Update the displayed data in the most prevelent live activity.
    private func updateLiveActivity() {
        guard let activityID = activityID,
              let activity = Activity<GPSTrackingAttributes>.activities.first(where: { $0.id == activityID })
        else { return }
        let newContentState = GPSTrackingAttributes.ContentState(
            userLongitude: locationsHandler.lastLocation.coordinate.longitude,
            userLatitude: locationsHandler.lastLocation.coordinate.latitude,
            seconds: Double(continuousTimeTrack),
            speed: speed,
            highPoint: gpsMap.heightMax,
            lowPoint: gpsMap.heightMin,
            distance: gpsMap.distance,
            positionNotation: locationDisplayType
        )
        let activityContent = ActivityContent(state: newContentState, staleDate: .now + 5)
        Task { await activity.update(activityContent) }
    }
    
    /// End the most prevelent live activity.
    private func endLiveActivity() {
        guard let activityID = activityID,
              let runningActiivty = Activity<GPSTrackingAttributes>.activities.first(where: { $0.id == activityID })
        else { return }
        locationsHandler.endAlwaysLocation()
        // Last small amount of data
        let newContentState = GPSTrackingAttributes.ContentState(
            userLongitude: locationsHandler.lastLocation.coordinate.longitude,
            userLatitude: locationsHandler.lastLocation.coordinate.latitude,
            seconds: Double(continuousTimeTrack),
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
