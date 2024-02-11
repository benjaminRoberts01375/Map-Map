//
//  NewGPSDrawerV.swift
//  Map Map
//
//  Created by Ben Roberts on 2/9/24.
//

import SwiftUI

struct NewGPSDrawerContentV: View {
    @Environment(\.managedObjectContext) var moc
    @Binding var workingName: String
    @ObservedObject var gpsMap: GPSMap
    
    var body: some View {
        VStack {
            HStack {
                TextField("GPS Map Name", text: $workingName)
                    .padding(.all, 5)
                    .background(Color.gray.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: 205)
            }
            HStack {
                Button { gpsMap.unwrappedEditing = .tracking } label: { Text("Start").bigButton(backgroundColor: .green) }
                Button { moc.delete(gpsMap) } label: { Text("Nevermind").bigButton(backgroundColor: .red) }
            }
        }
    }
}
