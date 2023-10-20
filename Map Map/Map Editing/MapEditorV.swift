//
//  MapEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/9/23.
//

import SwiftUI

struct MapEditor: View {
    @ObservedObject var map: FetchedResults<MapPhoto>.Element
    @Environment(\.managedObjectContext) var moc
    @State var workingName: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            AnyView(map.getMap(.fullImage))
            Spacer()
            HStack {
                Button(action: {
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
        .onAppear {
            map.mapName = workingName
        }
    }
}
