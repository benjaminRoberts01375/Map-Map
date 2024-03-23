//
//  MeasurementEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 12/15/23.
//

import Bottom_Drawer
import MapKit
import SwiftUI

struct MeasurementEditorV: View {
    /// Information about the map being plotted on top of.
    @Environment(MapDetailsM.self) var mapDetails
    /// All available Markers.
    @FetchRequest(sortDescriptors: []) var markers: FetchedResults<Marker>
    /// Measurement to edit.
    @FetchRequest(sortDescriptors: []) var measurements: FetchedResults<MapMeasurementCoordinate>
    /// Managed object context the measurement is stored in.
    @Environment(\.managedObjectContext) private var moc
    /// Real-world distance between the start and end points.
    @State private var distance: Measurement<UnitLength> = Measurement(value: .zero, unit: .meters)
    /// Screen-space position of the measuring point.
    @State private var startingPos: CGSize = .zero
    /// Screen-space position of the ending point.
    @State private var endingPos: CGSize = .zero
    /// Track if dragging is currently happening.
    @State private var isDragging: Bool = false
    /// Handle being edited.
    @State private var selectedMeasurement: MapMeasurementCoordinate?
    /// All screen-space positions of the handles.
    @State private var handlePositions: [MapMeasurementCoordinate : CGSize] = [:]
    /// Editor being used.
    @Binding var editing: Editor
    
    /// Basic orientation and positioning for a line
    enum Orientation {
        case leftVertical
        case rightVertical
        case topHorizontal
        case bottomHorizontal
    }
    
    /// Drag gesture for creating a line from scratch.
    var drawGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { update in
                if !isDragging {
                    if let selectedMeasurement = selectedMeasurement,
                        let measurementPos = mapDetails.mapProxy?.convert(selectedMeasurement.coordinates, to: .global) {
                        startingPos = CGSize(cgPoint: measurementPos)
                    }
                    else { startingPos = CGSize(cgPoint: update.startLocation) }
                    isDragging = true
                }
                let currentEndingPos = CGSize(cgPoint: update.location)
                if let snapPos = snapToMeasurement(currentEndingPos) { endingPos = snapPos.1 }
                else if let snapPos = snapToMarker(currentEndingPos) { endingPos = snapPos.1 }
                else { endingPos = currentEndingPos }
                
                guard let startingCoord = mapDetails.mapProxy?.convert(CGPoint(size: startingPos), from: .global),
                      let endingCoord = mapDetails.mapProxy?.convert(CGPoint(size: endingPos), from: .global)
                else { return }
                let startingLoc = CLLocation(latitude: startingCoord.latitude, longitude: startingCoord.longitude)
                let endingLoc = CLLocation(latitude: endingCoord.latitude, longitude: endingCoord.longitude)
                self.distance = Measurement(value: endingLoc.distance(from: startingLoc), unit: .meters)
            }
            .onEnded { _ in
                isDragging = false
                if let startingMeasurement = selectedMeasurement {
                    if let endingMeasurement = snapToMeasurement(endingPos) {
                        startingMeasurement.addToNeighbors(endingMeasurement.0)
                        self.selectedMeasurement = endingMeasurement.0
                    }
                    else {
                        guard let endingCoordinate = mapDetails.mapProxy?.convert(CGPoint(size: endingPos), from: .global)
                        else { return }
                        let endingMeasurement = MapMeasurementCoordinate(coordinate: endingCoordinate, insertInto: moc)
                        startingMeasurement.addToNeighbors(endingMeasurement)
                        self.selectedMeasurement = endingMeasurement
                    }
                }
                else {
                    if let endingMeasurement = snapToMeasurement(endingPos) {
                        guard let startingCoordinate = mapDetails.mapProxy?.convert(CGPoint(size: startingPos), from: .global)
                        else { return }
                        let startingMeasurement = MapMeasurementCoordinate(coordinate: startingCoordinate, insertInto: moc)
                        startingMeasurement.addToNeighbors(endingMeasurement.0)
                        self.selectedMeasurement = endingMeasurement.0
                    }
                    else {
                        guard let startingCoordinate = mapDetails.mapProxy?.convert(CGPoint(size: startingPos), from: .global),
                              let endingCoordinate = mapDetails.mapProxy?.convert(CGPoint(size: endingPos), from: .global)
                        else { return }
                        let startingMeasurement = MapMeasurementCoordinate(coordinate: startingCoordinate, insertInto: moc)
                        let endingMeasurement = MapMeasurementCoordinate(coordinate: endingCoordinate, insertInto: moc)
                        startingMeasurement.addToNeighbors(endingMeasurement)
                        self.selectedMeasurement = endingMeasurement
                    }
                }
                startingPos = .zero
                endingPos = .zero
                cleanupMeasurements()
            }
    }
    
    var body: some View {
        GeometryReader { _ in
            ZStack {
                Color.black
                    .opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture { selectedMeasurement = nil }
                    .accessibilityAddTraits(.isButton)
                    .gesture(drawGesture)
                if endingPos != startingPos {
                    ZStack {
                        Line(startingPos: startingPos, endingPos: endingPos)
                            .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                            .shadow(radius: 2)
                            .lineLabel(startingPos: CGPoint(size: startingPos), endingPos: CGPoint(size: endingPos), distance: distance)
                        if selectedMeasurement == nil { HandleV(position: $startingPos) }
                        HandleV(position: $endingPos)
                    }
                    .ignoresSafeArea()
                }
                
                ForEach(measurements) { measurement in
                    Button {
                        selectedMeasurement = measurement
                    } label: {
                        HandleV(
                            position: handlePositionBinding(for: measurement), 
                            color: selectedMeasurement == measurement ? Color.highlightBlue : HandleV.defaultColor,
                            deferPosition: true
                        )
                    }
                    .position(
                        x: handlePositions[measurement]?.width ?? .zero,
                        y: handlePositions[measurement]?.height ?? .zero
                    )
                }
                .ignoresSafeArea()
                
                BottomDrawer(verticalDetents: [.content], horizontalDetents: [.center]) { _ in
                    VStack {
                        Text("Drag to measure.")
                            .foregroundStyle(.secondary)
                        HStack {
                            // Done button
                            Button {
                                editing = .nothing
                                cleanupMeasurements()
                                try? moc.save()
                            } label: {
                                Text("Done")
                                    .bigButton(backgroundColor: .blue)
                            }
                            
                            // Delete button
                            Button( action: {
                                guard let selectedMeasurement = selectedMeasurement
                                else { return }
                                moc.delete(selectedMeasurement)
                                self.selectedMeasurement = nil
                                try? moc.save()
                            }, label: {
                                Text("Delete")
                                    .bigButton(backgroundColor: .red.opacity(selectedMeasurement != nil ? 1 : 0.5))
                            })
                            .disabled(selectedMeasurement == nil)
                        }
                    }
                }
            }
        }
        .onAppear {
            generateSSHandlePositions()
            mapDetails.preventFollowingUser()
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange)) { _ in
            generateSSHandlePositions()
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
            cleanupMeasurements()
        }
    }
    
    /// Create screen-space handle positions from coordinate positions.
    func generateSSHandlePositions() {
        var handlePositions: [MapMeasurementCoordinate : CGSize] = [:]
        
        for measurement in measurements {
            guard let ssPosition = mapDetails.mapProxy?.convert(measurement.coordinates, to: .global)
            else { continue }
            var updatedHandlePosition = CGSize(cgPoint: ssPosition)
            if let snapPoint = snapToMarker(updatedHandlePosition) { updatedHandlePosition = snapPoint.1 }
            handlePositions[measurement] = updatedHandlePosition
        }
        self.handlePositions = handlePositions
    }
    
    /// Create a binding from coordinates to CGSize
    func handlePositionBinding(for key: MapMeasurementCoordinate) -> Binding<CGSize> {
        Binding<CGSize>(
            get: { self.handlePositions[key] ?? .zero },
            set: { newVal in
                self.handlePositions[key] = newVal
                self.selectedMeasurement = key
                Task {
                    guard let mapCoords = mapDetails.mapProxy?.convert(CGPoint(size: newVal), from: .global)
                    else { return }
                    key.coordinates = mapCoords
                }
            }
        )
    }
    
    /// Delete invalid measurements.
    func cleanupMeasurements() {
        for measurement in measurements where measurement.formattedNeighbors.count == .zero {
            moc.delete(measurement)
        }
    }
    
    /// Check a CGSize position against other MapMeasurementCoordinate SS positions to see if it's within snapping range.
    /// - Parameter point: Point to check against other MapMeasurementCoordinate SS positions.
    /// - Returns: The first found MapMeasurementCoordinate and it's position on screen.
    private func snapToMeasurement(_ point: CGSize) -> (MapMeasurementCoordinate, CGSize)? {
        for measurement in measurements {
            guard let handlePosition = handlePositions[measurement]
            else { continue }
            if handlePosition.distanceTo(point) < HandleV.handleSize {
                return (measurement, handlePosition)
            }
        }
        return nil
    }
    
    /// Check a CGSize position against other Marker SS positions to see if it's within snapping range.
    /// - Parameter point: Point to check against other Marker SS positions.
    /// - Returns: The first found Marker and it's position on screen.
    private func snapToMarker(_ point: CGSize) -> (Marker, CGSize)? {
        for marker in markers {
            guard let markerPoint = mapDetails.mapProxy?.convert(marker.coordinate, to: .global)
            else { continue }
            let markerPosition = CGSize(cgPoint: markerPoint)
            if markerPosition.distanceTo(point) < HandleV.handleSize {
                return (marker, markerPosition)
            }
        }
        return nil
    }
}
