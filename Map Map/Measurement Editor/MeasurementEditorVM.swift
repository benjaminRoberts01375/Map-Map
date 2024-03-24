//
//  MeasurementEditorVM.swift
//  Map Map
//
//  Created by Ben Roberts on 3/24/24.
//

import SwiftUI

extension MeasurementEditorV {
    @Observable
    final class ViewModel {
        /// Real-world distance between the start and end points.
        var distance: Measurement<UnitLength> = Measurement(value: .zero, unit: .meters)
        /// Screen-space position of the measuring point.
        var startingPos: CGSize = .zero
        /// Screen-space position of the ending point.
        var endingPos: CGSize = .zero
        /// Track if dragging is currently happening.
        var isDragging: Bool = false
        /// Handle being edited.
        var selectedMeasurement: MapMeasurementCoordinate?
        /// All screen-space positions of the handles.
        var handlePositions: [MapMeasurementCoordinate : CGSize] = [:]
        /// Editor being used.
        @ObservationIgnored 
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
