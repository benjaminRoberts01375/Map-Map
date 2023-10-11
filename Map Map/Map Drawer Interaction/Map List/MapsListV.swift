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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Your Maps")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom)
            VStack(spacing: 0) {
                ForEach(maps) { photo in
                    MapListItem(photo: photo)
                        .background(colorScheme == .dark ? Color.init(red: 0.2, green: 0.2, blue: 0.2) : Color.white)
                        .contextMenu {
                            Button(role: .destructive) {
                                moc.delete(photo)
                                try? moc.save()
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button {
                                photo.needsEditing()
                                mapProcessing = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                        }
                    Divider()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .fullScreenCover(
            isPresented: $mapProcessing,
            content: { MapsEditor() }
        )
    }
}
