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
                .background(colorScheme == .dark ? .gray20 : Color.white)
                .contextMenu { MapMapContextMenuV(mapMap: map) }
                Divider()
            }
        }
        .ignoresSafeArea()
        .background(colorScheme == .dark ? .gray20 : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}
