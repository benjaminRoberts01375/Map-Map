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
            }
        }
        .onChange(of: selectedRangeIndicies) { _, newValue in
            print(newValue)
        }
    }
}
