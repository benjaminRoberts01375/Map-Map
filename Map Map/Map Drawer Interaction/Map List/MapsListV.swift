//
//  MapListV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/8/23.
//

import SwiftUI

struct MapList: View {
    @FetchRequest(sortDescriptors: []) var maps: FetchedResults<MapPhoto>
    @Environment(\.managedObjectContext) var moc
    @Environment(\.colorScheme) var colorScheme
    @State var mapProcessing = false
    let darkColor: Color = Color.init(red: 0.2, green: 0.2, blue: 0.2)
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(maps) { map in
                MapListItem(photo: map)
                    .padding(.leading)
                    .background(colorScheme == .dark ? darkColor : Color.white)
                    .contextMenu {
                        Button(role: .destructive) {
                            moc.delete(map)
                            try? moc.save()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        Button {
                            map.needsEditing()
                            mapProcessing = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                    }
                Divider()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .fullScreenCover(
            isPresented: $mapProcessing,
            content: { MapsEditor() }
        )
    }
}
