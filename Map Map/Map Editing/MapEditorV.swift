//
//  MapEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/9/23.
//

import SwiftUI

struct MapEditor: View {
    @ObservedObject var map: FetchedResults<MapPhoto>.Element
    @EnvironmentObject var mapDetails: MapDetailsM
    @Environment(\.managedObjectContext) var moc
    @State var workingName: String = ""
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            AnyView(map.getMap(.fullImage))
                .opacity(0.5)
                .allowsHitTesting(false)
            Spacer()
            TextField("\(Image(systemName: "pencil")) Map name", text: $workingName)
                .padding(.all, 5)
                .background(.gray)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 10)
                .frame(width: 205)
            HStack {
                Button(action: {
                    map.coordinates = mapDetails.position
                    map.rotation = NSDecimalNumber(value: mapDetails.rotation.degrees)
                    map.scale = NSDecimalNumber(value: 1.0 / mapDetails.scale)
                    map.mapName = workingName
                    map.isEditing = false
                    try? moc.save()
                }, label: {
                    Text("Done")
                        .bigButton(backgroundColor: .blue)
                })
                Button(action: {
                    moc.delete(map)
                    try? moc.save()
                }, label: {
                    Text("Cancel")
                        .bigButton(backgroundColor: .gray)
                })
            }
        }
        .onAppear { workingName = map.mapName ?? "Unknown name" }
    }
}
