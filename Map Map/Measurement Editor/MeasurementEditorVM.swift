//
//  MeasurementEditorVM.swift
//  Map Map
//
//  Created by Ben Roberts on 3/24/24.
//

import CoreData
import MapKit
import SwiftUI

extension MeasurementEditorV {
    @Observable
    internal final class ViewModel {
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
        
        init(editing: Binding<Editor>) {
            self._editing = editing
        }
    }
    
    /// Basic orientation and positioning for a line
    enum Orientation {
        case leftVertical
        case rightVertical
        case topHorizontal
        case bottomHorizontal
    }
    
    func preDrag(startLocation: CGSize) {
        if let selectedMeasurement = viewModel.selectedMeasurement,
           let measurementPos = mapDetails.mapProxy?.convert(selectedMeasurement.coordinates, to: .global) {
            viewModel.startingPos = CGSize(cgPoint: measurementPos)
        }
        else { viewModel.startingPos = startLocation }
        viewModel.isDragging = true
    }
    
    func snapToAnything(dragPosition: CGSize) {
        if let snapPos = snapToMeasurement(dragPosition) { viewModel.endingPos = snapPos.1 } // Found a measurement to snap to
        else if let snapPos = snapToMarker(dragPosition) { viewModel.endingPos = snapPos.1 } // Found a marker to snap to
        else { viewModel.endingPos = dragPosition } // Nothing snapped
    }
    
    func calculateDistanceBetweenPoints() -> Measurement<UnitLength>? {
        guard let startingCoord = mapDetails.mapProxy?.convert(CGPoint(size: viewModel.startingPos), from: .global),
              let endingCoord = mapDetails.mapProxy?.convert(CGPoint(size: viewModel.endingPos), from: .global)
        else { return nil }
        let startingLoc = CLLocation(latitude: startingCoord.latitude, longitude: startingCoord.longitude)
        let endingLoc = CLLocation(latitude: endingCoord.latitude, longitude: endingCoord.longitude)
        return Measurement(value: endingLoc.distance(from: startingLoc), unit: .meters)
    }
    
    func combineSnapStartMeasurement(startingMeasurement: MapMeasurementCoordinate) {
        if let endingMeasurement = snapToMeasurement(viewModel.endingPos) {
            startingMeasurement.addToNeighbors(endingMeasurement.0)
            viewModel.selectedMeasurement = endingMeasurement.0
        }
        else {
            guard let endingCoordinate = mapDetails.mapProxy?.convert(CGPoint(size: viewModel.endingPos), from: .global)
            else { return }
            let endingMeasurement = MapMeasurementCoordinate(coordinate: endingCoordinate, insertInto: moc)
            startingMeasurement.addToNeighbors(endingMeasurement)
            viewModel.selectedMeasurement = endingMeasurement
        }
    }
    
    func combineSnapStartMeasurement() {
        if let endingMeasurement = snapToMeasurement(viewModel.endingPos) {
            guard let startingCoordinate = mapDetails.mapProxy?.convert(CGPoint(size: viewModel.startingPos), from: .global)
            else { return }
            let startingMeasurement = MapMeasurementCoordinate(coordinate: startingCoordinate, insertInto: moc)
            startingMeasurement.addToNeighbors(endingMeasurement.0)
            viewModel.selectedMeasurement = endingMeasurement.0
        }
        else {
            guard let startingCoordinate = mapDetails.mapProxy?.convert(CGPoint(size: viewModel.startingPos), from: .global),
                  let endingCoordinate = mapDetails.mapProxy?.convert(CGPoint(size: viewModel.endingPos), from: .global)
            else { return }
            let startingMeasurement = MapMeasurementCoordinate(coordinate: startingCoordinate, insertInto: moc)
            let endingMeasurement = MapMeasurementCoordinate(coordinate: endingCoordinate, insertInto: moc)
            startingMeasurement.addToNeighbors(endingMeasurement)
            viewModel.selectedMeasurement = endingMeasurement
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
        viewModel.handlePositions = handlePositions
    }
    
    /// Create a binding from coordinates to CGSize
    func handlePositionBinding(for key: MapMeasurementCoordinate) -> Binding<CGSize> {
        Binding<CGSize>(
            get: { viewModel.handlePositions[key] ?? .zero },
            set: { newVal in
                viewModel.handlePositions[key] = newVal
                viewModel.selectedMeasurement = key
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
            guard let handlePosition = viewModel.handlePositions[measurement]
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
