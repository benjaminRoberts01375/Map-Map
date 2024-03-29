//
//  GPSMapBranches.swift
//  Map Map
//
//  Created by Ben Roberts on 2/23/24.
//

import SwiftUI

struct GPSMapBranchesV: View {
    /// The current managed object context.
    @Environment(\.managedObjectContext) var moc
    /// GPSMap containing GPSMapBranches.
    @ObservedObject var gpsMap: GPSMap
    /// The current editing mode of the UI.
    @Binding var editingMode: GPSMapPhaseController.EditingMode
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    editingMode = .editing
                } label: {
                    Image(systemName: "chevron.backward")
                        .symbolRenderingMode(.hierarchical)
                        .resizable()
                        .scaledToFit()
                        .accessibilityLabel("Go back")
                        .frame(width: 22, height: 22)
                        .padding(4)
                }
                Spacer()
                Text("Branches")
                    .font(.title3)
                Spacer()
                Button {
                    let newBranch = GPSMapBranch(name: "New Branch", moc: moc)
                    gpsMap.addToBranches(newBranch)
                    editingMode = .editingBranch(newBranch)
                } label: {
                    Image(systemName: "plus")
                        .symbolRenderingMode(.hierarchical)
                        .resizable()
                        .accessibilityLabel("Add branch")
                        .frame(width: 22, height: 22)
                        .padding(4)
                }
                
            }
            ScrollView(.horizontal) {
                HStack {
                    ForEach(gpsMap.unwrappedBranches) { branch in
                        Button {
                            self.editingMode = .editingBranch(branch)
                        } label: {
                            Text(branch.name ?? "Branch")
                                .allowsTightening(true)
                                .padding(.horizontal, 5)
                                .foregroundStyle(branch.branchColor.contrastColor)
                                .bigButton(backgroundColor: branch.branchColor, maxWidth: 150)
                                .shadow(radius: 2)
                        }
                    }
                }
            }
            .onAppear { print(gpsMap.unwrappedBranches.count) }
        }
    }
}
