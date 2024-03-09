//
//  GPSMapBranchEditingV.swift
//  Map Map
//
//  Created by Ben Roberts on 2/23/24.
//

import RangeSlider
import SwiftUI

struct GPSMapBranchEditingV: View {
    @ObservedObject var gpsMapBranch: GPSMapBranch
    @State private var workingName: String
    let rangeIndicies: ClosedRange<Double>
    @State var selectedRangeIndicies: ClosedRange<Double>
    @Environment(\.managedObjectContext) var moc
    @State var originalConnectionAssignments: [GPSMapCoordinateConnection : GPSMapBranch] = [:]
    
    init(gpsMapBranch: GPSMapBranch) {
        self.gpsMapBranch = gpsMapBranch
        self.workingName = gpsMapBranch.name ?? ""
        self.rangeIndicies = 0...Double(gpsMapBranch.gpsMap?.unwrappedConnections.count ?? 0)
        self.selectedRangeIndicies = rangeIndicies
        guard let firstConnection = gpsMapBranch.unwrappedConnections.first,
              let lastConnection = gpsMapBranch.unwrappedConnections.last,
              let firstIndex = gpsMapBranch.gpsMap?.unwrappedConnections.firstIndex(where: { $0 == firstConnection }),
              let lastIndex = gpsMapBranch.gpsMap?.unwrappedConnections.firstIndex(where: { $0 == lastConnection })
        else { return }
        self.selectedRangeIndicies = Double(firstIndex)...Double(lastIndex)
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
        }
        .onChange(of: selectedRangeIndicies) { oldValue, newValue in
            adjustConnectedBranches(oldIndicies: oldValue, newIndicies: newValue)
        }
        .task {
            guard let gpsMap = gpsMapBranch.gpsMap else { return }
            var connectionAssignments: [GPSMapCoordinateConnection : GPSMapBranch] = [:]
            for connection in gpsMap.unwrappedConnections {
                connectionAssignments[connection] = connection.branch
            }
            DispatchQueue.main.async {
                self.originalConnectionAssignments = connectionAssignments
                guard let connections = gpsMapBranch.gpsMap?.unwrappedConnections // Get all connections
                else { return }
                for connection in connections {
                    gpsMapBranch.addToConnections(connection)
                }
            }
        }
    }
    
    func adjustConnectedBranches(oldIndicies: ClosedRange<Double>, newIndicies: ClosedRange<Double>) {
        guard var connections = ensureValidRange(oldIndicies: oldIndicies) else { return }
        updateUpperBound(oldIndicies: oldIndicies, newIndicies: newIndicies, connections: &connections)
        updateLowerBound(oldIndicies: oldIndicies, newIndicies: newIndicies, connections: &connections)
        gpsMapBranch.objectWillChange.send()
    }
    
    func ensureValidRange(oldIndicies: ClosedRange<Double>) -> [GPSMapCoordinateConnection]? {
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
            for index in stride(from: Int(newIndicies.lowerBound) - 1, through: Int(oldIndicies.lowerBound), by: -1) {
                if let branch = originalConnectionAssignments[connections[index]] {
                    branch.addToConnections(connections[index])
                }
                else { self.gpsMapBranch.removeFromConnections(connections[index]) }
            }
        }
    }
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
            for index in stride(from: Int(oldIndicies.upperBound) - 1, through: Int(newIndicies.upperBound), by: -1) {
                if let branch = originalConnectionAssignments[connections[index]] {
                    branch.addToConnections(connections[index])
                }
                else { self.gpsMapBranch.removeFromConnections(connections[index]) }
            }
        }
    }
}
