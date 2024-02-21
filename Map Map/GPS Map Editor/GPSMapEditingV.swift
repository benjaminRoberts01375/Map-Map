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
    @State private var mode: EditingMode = .editing
    
    private enum EditingMode {
        case editing
        case painting
    }
    
    init(_ gpsMap: GPSMap) {
        self.workingName = gpsMap.name ?? ""
        self.gpsMap = gpsMap
    }
    
    var body: some View {
        VStack {
            HStack {
                TextField("GPS Map name", text: $workingName)
                    .padding(.all, 5)
                    .background(Color.gray.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: 205)
                Button{
                    self.mode = .painting
                } label: {
                    Image(systemName: "paintbrush.pointed.fill")
                        .accessibilityLabel("Markup MapMap")
                        .padding(4)
                        .background(.gray)
                        .clipShape(Circle())
                }
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
