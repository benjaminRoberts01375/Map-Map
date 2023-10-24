//
//  MapListV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/8/23.
//

import MapKit
import SwiftUI

struct MapMapList: View {
    @EnvironmentObject var backgroundMapDetails: BackgroundMapDetailsM
    @FetchRequest(sortDescriptors: []) var mapMaps: FetchedResults<MapMap>
    @Environment(\.managedObjectContext) var moc
    @Environment(\.colorScheme) var colorScheme
    let darkColor: Color = Color.init(red: 0.2, green: 0.2, blue: 0.2)
    let listMode: ListMode
    
    var body: some View {
        VStack(alignment: listMode == .compact ? .center : .leading, spacing: 0) {
            ForEach(mapMaps) { map in
                Button(action: {
                    withAnimation {
                        backgroundMapDetails.mapCamera = .camera(MapCamera(centerCoordinate: map.coordinates, distance: map.mapDistance, heading: -map.mapMapRotation))
                    }
                }, label: {
                    switch listMode {
                    case .compact:
                        CompactMapListItem(mapMap: map)
                            .padding()
                    case .full:
                        MapMapListItem(mapMap: map)
                            .padding()
                    }
                })
                .buttonStyle(.plain)
                .background(colorScheme == .dark ? darkColor : Color.white)
                .contextMenu {
                    Button(role: .destructive) {
                        moc.delete(map)
                        try? moc.save()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    Button {
                        map.isEditing = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                }
                Divider()
            }
        }
        .ignoresSafeArea()
        .background(colorScheme == .dark ? darkColor : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}
