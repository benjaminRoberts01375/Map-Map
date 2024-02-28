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
    let isDefaultBranch: Bool
    
    init(gpsMapBranch: GPSMapBranch) {
        self.gpsMapBranch = gpsMapBranch
        self.workingName = gpsMapBranch.name ?? ""
        self.rangeIndicies = 0...Double(gpsMapBranch.gpsMap?.allConnections.count ?? 0)
        self.selectedRangeIndicies = rangeIndicies
        self.isDefaultBranch = gpsMapBranch.gpsMap?.unwrappedBranches.first == gpsMapBranch
        guard let firstConnection = gpsMapBranch.unwrappedConnections.first,
              let lastConnection = gpsMapBranch.unwrappedConnections.last,
              let firstIndex = gpsMapBranch.gpsMap?.allConnections.firstIndex(where: { $0 == firstConnection }),
              let lastIndex = gpsMapBranch.gpsMap?.allConnections.firstIndex(where: { $0 == lastConnection })
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
            if !isDefaultBranch {
                HorizontalRangeSliderV(value: $selectedRangeIndicies, range: rangeIndicies)
            }
        }
        .onChange(of: selectedRangeIndicies) { _, newValue in
            print(newValue)
        }
    }
}
