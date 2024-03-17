//
//  mapPointsV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/20/23.
//

import ActivityKit
import MapKit
import SwiftUI

/// Points that cannot be Annotations on the map.
struct MapPointsV: View {
    /// Information about the map.
    @Environment(MapDetailsM.self) private var mapDetails
    /// All available markers.
    @FetchRequest(sortDescriptors: []) private var markers: FetchedResults<Marker>
    /// All available measurements.
    @FetchRequest(sortDescriptors: []) private var measurementCoordinates: FetchedResults<MapMeasurementCoordinate>
    /// All available GPSMaps.
    @FetchRequest(sortDescriptors: []) private var gpsMaps: FetchedResults<GPSMap>
    /// GPS user location.
    @State private var locationsHandler = LocationsHandler.shared
    /// The user's location in screen-space
    @State private var ssUserLocation: CGPoint?
    /// Size of the parent view.
    let screenSize: CGSize
    /// Marker icon size.
    static let iconSize: CGFloat = 30
    /// User location icon size.
    private let userLocationSize: CGFloat = 24
    /// Offset marker slightly for correct alignment.
    private let markerOffset: CGFloat = -2
    /// Min line length
    static let minLineLength: CGFloat = 70
    /// All connections made by the MapMeasurementCoordinates. Should be rarely calculated.
    @State var lines: [Connection] = []
    /// Screen space positions of all line start and end points.
    @State var lineEnds: [MapMeasurementCoordinate : CGPoint] = [:]
    /// Track if the app is currently in the foreground.
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(lines) { connection in
                    if let startingPos = lineEnds[connection.start], // Valid starting point
                       let endingPos = lineEnds[connection.end], // Valid ending point
                       startingPos.distanceTo(endingPos) > MapPointsV.minLineLength && // Distance is greater than min
                       (pointIsInBounds(startingPos, screenSize: geo.size) || // Point is within threshold
                        pointIsInBounds(endingPos, screenSize: geo.size)) { // Point is within threshold
                        Line(startingPos: CGSize(cgPoint: startingPos), endingPos: CGSize(cgPoint: endingPos)) // Outline line
                            .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .foregroundStyle(.black.opacity(0.5))
                        Line(startingPos: CGSize(cgPoint: startingPos), endingPos: CGSize(cgPoint: endingPos)) // Foreground line
                            .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                            .lineLabel(
                                startingPos: startingPos,
                                endingPos: endingPos,
                                distance: connection.distance
                            )
                    }
                }
            }
            .allowsHitTesting(false)
            
            ForEach(gpsMaps) { gpsMap in
                GPSMapV(gpsMap: gpsMap)
            }
            
            ForEach(markers) { marker in
                if let position = mapDetails.mapProxy?.convert(marker.coordinate, to: .global), !marker.isEditing && marker.shown {
                    ZStack {
                        Button {
                            mapDetails.moveMapCameraTo(item: marker)
                        } label: {
                            MarkerV(marker: marker)
                                .rotationEffect(
                                    Angle(degrees: -mapDetails.mapCamera.heading -
                                          (marker.lockRotationAngleDouble ?? -mapDetails.mapCamera.heading))
                                )
                                .offset(y: markerOffset)
                        }
                        .contextMenu { MarkerContextMenuV(marker: marker) }
                        .frame(width: MapPointsV.iconSize, height: MapPointsV.iconSize)
                        if let markerName = marker.name, isOverMarker(marker) {
                            Text(markerName)
                                .mapLabel()
                                .foregroundStyle(.white)
                                .allowsHitTesting(false)
                                .offset(y: MapPointsV.iconSize)
                        }
                    }
                    .position(position)
                }
            }
            VStack {
                let userLocation = CLLocationCoordinate2D(
                    latitude: locationsHandler.lastLocation.coordinate.latitude,
                    longitude: locationsHandler.lastLocation.coordinate.longitude
                )
                if let screenSpaceUserLocation = mapDetails.mapProxy?.convert(userLocation, to: .global) {
                    MapUserIcon()
                        .frame(width: userLocationSize, height: userLocationSize)
                        .position(screenSpaceUserLocation)
                }
                else { EmptyView() }
            }
            .ignoresSafeArea()
            .onAppear {
                self.lines = connectionsToDraw()
                locationsHandler.startLocationTracking()
            }
            .onDisappear { locationsHandler.stopLocationTracking() }
            .onChange(of: locationsHandler.lastLocation) { _, update in
                let userCoords = CLLocationCoordinate2D(
                    latitude: update.coordinate.latitude,
                    longitude: update.coordinate.longitude
                )
                if let ssUserLocation = mapDetails.mapProxy?.convert(userCoords, to: .global) {
                    self.ssUserLocation = ssUserLocation
                }
            }
            .animation(.linear, value: ssUserLocation)
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange)) { interpretCDNotification($0) }
        .onChange(of: mapDetails.mapCamera) {
            Task {
                let positions = await calculateSSlineEndPos()
                DispatchQueue.main.async { self.lineEnds = positions }
            }
        }
        .onChange(of: scenePhase) {
            switch scenePhase {
            case .active: locationsHandler.startLocationTracking()
            default: if Activity<GPSTrackingAttributes>.activities.isEmpty { locationsHandler.stopLocationTracking() }
            }
        }
    }
    
    func isOverMarker(_ marker: Marker) -> Bool {
        guard let markerPos = mapDetails.mapProxy?.convert(marker.coordinate, to: .global) else { return false }
        let xComponent = abs(markerPos.x - screenSize.width / 2)
        let yComponent = abs(markerPos.y - (screenSize.height / 2 - markerOffset))
        let distance = sqrt(pow(xComponent, 2) + pow(yComponent, 2))
        return distance < MapPointsV.iconSize / 2
    }
    
    func connectionsToDraw() -> [Connection] {
        var visited: Set<MapMeasurementCoordinate> = []
        var connections: [Connection] = []
        for firstNode in measurementCoordinates {
            if visited.contains(firstNode) { continue }
            var queue: Set<MapMeasurementCoordinate> = [firstNode]
            
            while !queue.isEmpty {
                let current = queue.removeFirst()
                for connectedNode in current.formattedNeighbors {
                    if visited.contains(connectedNode) { continue }
                    queue.insert(connectedNode)
                    connections.append(Connection(connectedNode, current))
                }
                visited.insert(current)
            }
        }
        return connections
    }
    
    func calculateSSlineEndPos() async -> [MapMeasurementCoordinate : CGPoint] {
        var result: [MapMeasurementCoordinate : CGPoint] = [:]
        for line in lines {
            result[line.start] = mapDetails.mapProxy?.convert(line.start.coordinates, to: .global)
            result[line.end] = mapDetails.mapProxy?.convert(line.end.coordinates, to: .global)
        }
        return result
    }
    
    func pointIsInBounds(_ point: CGPoint, screenSize: CGSize) -> Bool {
        let padding = 1.3
        return (point.x > -screenSize.width * padding) &&
        (point.x < screenSize.width * padding) &&
        (point.y > -screenSize.height * padding) &&
        (point.y < screenSize.height * padding)
    }
    
    /// Based on the notification ``NSManagedObjectContextObjectsDidChange`` Core Data notification, check to see how Core Data has updated,
    /// and if it's neccessary for the displayed connections.
    /// If it is neccessary, then update as needed.
    /// - Parameter notification: Notification from Core Data
    private func interpretCDNotification(_ notification: NotificationCenter.Publisher.Output) {
        for userInfoElement in notification.userInfo ?? [:] {
            if let message = userInfoElement.key as? String {
                if message == .invalidatedAll || message == .deleted || message == .inserted {
                    self.lines = connectionsToDraw()
                    break
                }
                else if message == .update, let mapCoordinates = userInfoElement.value as? Set<MapMeasurementCoordinate> {
                    if mapCoordinates.count > 1 { self.lines = connectionsToDraw() }
                    updateCoordinate(mapCoordinates)
                }
            }
        }
        Task {
            let positions = await calculateSSlineEndPos()
            DispatchQueue.main.async { self.lineEnds = positions }
        }
    }
    
    /// Update lines to use correct distances.
    /// - Parameter mapCoordinates: Map Coordinates to be updated.
    private func updateCoordinate(_ mapCoordinates: Set<MapMeasurementCoordinate>) {
        for mapCoordinate in mapCoordinates {
            for lineIndex in lines.indices {
                if lines[lineIndex].start == mapCoordinate {
                    let startLocation = CLLocation(latitude: mapCoordinate.latitude, longitude: mapCoordinate.longitude)
                    let endLocation = CLLocation(latitude: lines[lineIndex].end.latitude, longitude: lines[lineIndex].end.longitude)
                    lines[lineIndex].distance = Measurement(value: endLocation.distance(from: startLocation), unit: .meters)
                }
                else if lines[lineIndex].end == mapCoordinate {
                    let startLocation = CLLocation(latitude: mapCoordinate.latitude, longitude: mapCoordinate.longitude)
                    let endLocation = CLLocation(latitude: lines[lineIndex].start.latitude, longitude: lines[lineIndex].start.longitude)
                    lines[lineIndex].distance = Measurement(value: endLocation.distance(from: startLocation), unit: .meters)
                }
            }
        }
    }
}
