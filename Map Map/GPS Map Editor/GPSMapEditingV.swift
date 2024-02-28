//
//  GPSMapEditing.swift
//  Map Map
//
//  Created by Ben Roberts on 2/21/24.
//

import SwiftUI

struct GPSMapEditingV: View {
    @State var workingName: String
    @ObservedObject var gpsMap: GPSMap
    @Environment(\.managedObjectContext) var moc
    @Binding var editingMode: GPSMapPhaseController.EditingMode
    
    init(_ gpsMap: GPSMap, editingMode: Binding<GPSMapPhaseController.EditingMode>) {
        self.workingName = gpsMap.name ?? ""
        self.gpsMap = gpsMap
        self._editingMode = editingMode
    }
    
    var body: some View {
        VStack {
            HStack {
                TextField("GPS Map name", text: $workingName)
                    .padding(.all, 5)
                    .background(Color.gray.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: 205)
                Button(action: {
                    editingMode = .selectingBranch
                }, label: {
                    Image(systemName: "arrow.triangle.branch")
                        .accessibilityLabel("View GPS Map bsranches")
                        .padding(4)
                        .background(.gray)
                        .clipShape(Circle())
                })
                .buttonStyle(.plain)
            }
            HStack {
                Button(
                    action: { gpsMap.unwrappedEditing = .viewing },
                    label: { Text("Done").bigButton(backgroundColor: .blue) }
                )
                Button(action: {
                    moc.reset()
                }, label: {
                    Text("Cancel")
                        .bigButton(backgroundColor: .gray)
                })
                Button( action: {
                    moc.delete(gpsMap)
                    try? moc.save()
                }, label: {
                    Text("Delete")
                })
                .bigButton(backgroundColor: .red)
            }
        }
    }
}