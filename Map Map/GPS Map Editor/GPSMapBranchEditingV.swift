//
//  GPSMapBranchEditingV.swift
//  Map Map
//
//  Created by Ben Roberts on 2/23/24.
//

import RangeSlider
import SwiftUI

struct GPSMapBranchEditingV: View {
    /// Current managed object context
    @Environment(\.managedObjectContext) var moc
    /// GPS Map Branch currently being edited.
    @ObservedObject var gpsMapBranch: GPSMapBranch
    /// Track the original assignments of GPSMapCoordinateConnection to branches before adjustments by this branch.
    @State var originalConnectionAssignments: [GPSMapCoordinateConnection : GPSMapBranch]?
    /// Unapplied name of the branch.
    @State private var workingName: String
    /// Current selection of the ranged slider
    @State var selectedRangeIndicies: ClosedRange<Double>
    /// Track and update the current editing mode of this branch.
    @Binding var editingMode: GPSMapPhaseController.EditingMode
    /// Allowed selection range of ranged slider.
    let rangeIndicies: ClosedRange<Double>
    
    /// Allow the user to edit a specific branch.
    /// - Parameters:
    ///   - gpsMapBranch: Branch to edit.
    ///   - editingMode: Current editing mode of the UI.
    init(gpsMapBranch: GPSMapBranch, editingMode: Binding<GPSMapPhaseController.EditingMode>) {
        self.gpsMapBranch = gpsMapBranch
        self.workingName = gpsMapBranch.name ?? ""
        self.rangeIndicies = 0...Double(gpsMapBranch.gpsMap?.unwrappedConnections.count ?? 0)
        if !gpsMapBranch.isSetup { self.selectedRangeIndicies = rangeIndicies }
        self._editingMode = editingMode
        guard let firstConnection = gpsMapBranch.unwrappedConnections.first,
              let lastConnection = gpsMapBranch.unwrappedConnections.last,
              let firstIndex = gpsMapBranch.gpsMap?.unwrappedConnections.firstIndex(where: { $0 == firstConnection }),
              let lastIndex = gpsMapBranch.gpsMap?.unwrappedConnections.firstIndex(where: { $0 == lastConnection })
        else {
            self.selectedRangeIndicies = rangeIndicies
            return
        }
        self.selectedRangeIndicies = // Crash prevention, may cause some minor UI bugs
        if firstIndex <= lastIndex { Double(firstIndex)...Double(lastIndex) }
        else { Double(lastIndex)...Double(firstIndex) }
    }
    
    var body: some View {
        VStack {
            HStack {
                TextField("Branch name", text: $workingName)
                    .padding(.all, 5)
                    .background(Color.gray.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: 205)
                ColorPicker("", selection: $gpsMapBranch.branchColor, supportsOpacity: false)
                    .labelsHidden()
            }
            HorizontalRangeSliderV(value: $selectedRangeIndicies, range: rangeIndicies)
                .allowsHitTesting(!originalConnectionAssignments.isEmpty)
            HStack {
                Button {
                    gpsMapBranch.name = workingName
                    self.gpsMapBranch.isSetup = true
                    editingMode = .selectingBranch
                    guard let gpsMap = gpsMapBranch.gpsMap else { return }
                    for branch in gpsMap.unwrappedBranches where branch.unwrappedConnections.isEmpty { moc.delete(branch) }
                } label: {
                    Text("Done")
                        .bigButton(backgroundColor: .blue)
                }
                Button {
                    moc.delete(gpsMapBranch)
                    editingMode = .selectingBranch
                } label: {
                    Text("Delete")
                        .bigButton(backgroundColor: .red)
                }
            }
        }
        .onChange(of: selectedRangeIndicies) { adjustConnectedBranches(oldIndicies: $0, newIndicies: $1) }
        .task {
            let assignments: [GPSMapCoordinateConnection : GPSMapBranch] = await saveCoordinateBranchAssignments()
            if !self.gpsMapBranch.isSetup {
                await MainActor.run { assignAllCoordinatesToBranch() }
            }
            await MainActor.run { self.originalConnectionAssignments = assignments }
        }
    }
    
    /// Save the original `GPSMapCoordinateConnection` branch assignments.
    /// - Returns: Assignments.
    func saveCoordinateBranchAssignments() async -> [GPSMapCoordinateConnection : GPSMapBranch] {
        guard let gpsMap = gpsMapBranch.gpsMap else { return [:] }
        var connectionAssignments: [GPSMapCoordinateConnection : GPSMapBranch] = [:]
        for connection in gpsMap.unwrappedConnections {
            connectionAssignments[connection] = connection.branch
        }
        return connectionAssignments
    }
    
    /// Recursively go through each of the coordinates to remember their assignment before being switched to this branch.
    func assignAllCoordinatesToBranch() {
        // Set every available coordinate to this branch
        guard let connections = gpsMapBranch.gpsMap?.unwrappedConnections // Get all connections
        else { return }
        for connection in connections {
            gpsMapBranch.addToConnections(connection)
        }
    }
    
    /// Interpret the UI's selection to update connections in this and other branches.
    /// - Parameters:
    ///   - oldIndicies: Old selection
    ///   - newIndicies: New selection
    func adjustConnectedBranches(oldIndicies: ClosedRange<Double>, newIndicies: ClosedRange<Double>) {
        guard var connections = ensureValidRange() else { return }
        updateUpperBound(oldIndicies: oldIndicies, newIndicies: newIndicies, connections: &connections)
        updateLowerBound(oldIndicies: oldIndicies, newIndicies: newIndicies, connections: &connections)
        gpsMapBranch.objectWillChange.send()
    }
    
    /// Check if the current range provided is valid.
    /// - Returns: Available connections for the given range.
    func ensureValidRange() -> [GPSMapCoordinateConnection]? {
        guard let connections = gpsMapBranch.gpsMap?.unwrappedConnections // Get all connections
        else {
            selectedRangeIndicies = rangeIndicies // Reset range
            return nil
        }
        
        // If either the selected lower or upper bound is out of bounds, fix them
        if selectedRangeIndicies.lowerBound < rangeIndicies.lowerBound {
            selectedRangeIndicies = rangeIndicies.lowerBound...selectedRangeIndicies.upperBound
        }
        if selectedRangeIndicies.upperBound > rangeIndicies.upperBound {
            selectedRangeIndicies = selectedRangeIndicies.lowerBound...rangeIndicies.upperBound
        }
        return connections
    }
    
    /// Handles lower insertion and removal of lower range.
    /// - Parameters:
    ///   - oldIndicies: Previous assignment of connections to this branch.
    ///   - newIndicies: New assignment of connections to this branch.
    ///   - connections: All available connections.
    private func updateLowerBound(
        oldIndicies: ClosedRange<Double>,
        newIndicies: ClosedRange<Double>,
        connections: inout [GPSMapCoordinateConnection]
    ) {
        // If the old index of lower bound is less than the new one (got slid down)
        if oldIndicies.lowerBound > newIndicies.lowerBound {
            for index in Int(newIndicies.lowerBound)..<Int(oldIndicies.lowerBound) {
                gpsMapBranch.insertIntoConnections(connections[index], at: 0)
            }
        }
        // If old index of lower bound is greater than new one (got slid up)
        else if oldIndicies.lowerBound < newIndicies.lowerBound {
            guard let originalConnectionAssignments = originalConnectionAssignments else { return }
            // Reverse for loop
            for index in stride(from: Int(newIndicies.lowerBound) - 1, through: Int(oldIndicies.lowerBound), by: -1) {
                if let branch = originalConnectionAssignments[connections[index]] {
                    branch.addToConnections(connections[index])
                }
                else { self.gpsMapBranch.removeFromConnections(connections[index]) }
            }
        }
    }
    
    /// Handles lower insertion and removal of upper range.
    /// - Parameters:
    ///   - oldIndicies: Previous assignment of connections to this branch.
    ///   - newIndicies: New assignment of connections to this branch.
    ///   - connections: All available connections.
    private func updateUpperBound(
        oldIndicies: ClosedRange<Double>,
        newIndicies: ClosedRange<Double>,
        connections: inout [GPSMapCoordinateConnection]
    ) {
        // If the new upper bound is greater than the old upper bound (got slid up)
        if newIndicies.upperBound > oldIndicies.upperBound {
            for index in Int(oldIndicies.upperBound)..<Int(newIndicies.upperBound) {
                gpsMapBranch.addToConnections(connections[index])
            }
        }
        // If the new upper bound is less than the old upper bound (got slid down)
        else if newIndicies.upperBound < oldIndicies.upperBound {
            guard let originalConnectionAssignments = originalConnectionAssignments else { return }
            for index in stride(from: Int(oldIndicies.upperBound) - 1, through: Int(newIndicies.upperBound), by: -1) {
                if let branch = originalConnectionAssignments[connections[index]] {
                    branch.addToConnections(connections[index])
                }
                else { self.gpsMapBranch.removeFromConnections(connections[index]) }
            }
        }
    }
}
