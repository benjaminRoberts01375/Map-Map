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
    
    init(_ gpsMap: GPSMap) {
        self.workingName = gpsMap.name ?? ""
        self.gpsMap = gpsMap
    }
    
    var body: some View {
        VStack {
            TextField("GPS Map name", text: $workingName)
                .padding(.all, 5)
                .background(Color.gray.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(width: 205)
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
