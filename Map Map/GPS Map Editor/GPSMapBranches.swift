//
//  GPSMapBranches.swift
//  Map Map
//
//  Created by Ben Roberts on 2/23/24.
//

import SwiftUI

struct GPSMapBranches: View {
    @ObservedObject var gpsMap: GPSMap
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
                ForEach(gpsMap.unwrappedBranches) { branch in
                    Button {
                        self.editingMode = .editingBranch(branch)
                    } label: {
                        Text(branch.name ?? "Branch")
                            .bigButton(backgroundColor: .blue)
                        
                    }
                }
            }
        }
    }
}
