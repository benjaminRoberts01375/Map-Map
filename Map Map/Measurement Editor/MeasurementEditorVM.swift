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
        @ObservationIgnored @Binding var editor: Editor
        var selectedCoordinateStart: MapMeasurementCoordinate?
        var selectedCoordinateEnd: MapMeasurementCoordinate?
        
        init(editor: Binding<Editor>) { self._editor = editor }
    }
    
    var newMeasurement: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { update in
                guard var newEndCoords = mapDetails.mapProxy?.convert(update.location, from: .global) else { return }
                if let selectedStartCoordinate = viewModel.selectedCoordinateStart { // If one is selected, start from it
                    // Check if there's an end. If not, make a new end coordinate.
                    if viewModel.selectedCoordinateEnd == nil {
                        viewModel.selectedCoordinateEnd = MapMeasurementCoordinate(coordinate: newEndCoords, insertInto: moc)
                    }
                    else {
                        viewModel.selectedCoordinateEnd?.coordinates = newEndCoords
                    }
                }
                else { // If none are selected, create two new coordinates.
                    guard var newStartCoords = mapDetails.mapProxy?.convert(update.startLocation, from: .global) else { return }
                    viewModel.selectedCoordinateStart = MapMeasurementCoordinate(coordinate: newStartCoords, insertInto: moc)
                    viewModel.selectedCoordinateEnd = MapMeasurementCoordinate(coordinate: newEndCoords, insertInto: moc)
                }
            }
    }
}
