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
        .onAppear {
            guard let gpsMap = gpsMapBranch.gpsMap else { return }
            _ = gpsMap.unwrappedConnections.map { $0.editing = .editing(gpsMapBranch) }
        }
    }
    
    func adjustConnectedBranches(oldIndicies: ClosedRange<Double>, newIndicies: ClosedRange<Double>) {
        guard let connections = gpsMapBranch.gpsMap?.unwrappedConnections // Get all connections
        else {
            selectedRangeIndicies = oldIndicies // Reset range
            return
        }
        // If either the selected lower or upper bound is out of bounds, return
        if selectedRangeIndicies.lowerBound < rangeIndicies.lowerBound ||
            selectedRangeIndicies.upperBound > rangeIndicies.upperBound {
            return
        }
        
        // If the old index of lower bound is less than the new one (got slid down)
        if oldIndicies.lowerBound > newIndicies.lowerBound {
            for index in Int(newIndicies.lowerBound)..<Int(oldIndicies.lowerBound) {
                connections[index].editing = .editing(gpsMapBranch)
            }
        }
        // If old index of lower bound is greater than new one (got slid up)
        else if oldIndicies.lowerBound < newIndicies.lowerBound {
            for index in Int(oldIndicies.lowerBound)..<Int(newIndicies.lowerBound) {
                connections[index].editing = .standard
            }
        }
        // If the new upper bound is greater than the old upper bound (got slid up)
        if newIndicies.upperBound > oldIndicies.upperBound {
            for index in Int(oldIndicies.upperBound)..<Int(newIndicies.upperBound) {
                connections[index].editing = .editing(gpsMapBranch)
            }
        }
        // If the new upper bound is less than the old upper bound (got slid down)
        else if newIndicies.upperBound < oldIndicies.upperBound {
            for index in Int(newIndicies.upperBound)..<Int(oldIndicies.upperBound) {
                connections[index].editing = .standard
            }
        }
    }
}
