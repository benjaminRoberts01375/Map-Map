//
//  MapItemV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/10/23.
//

import SwiftUI

struct MapMapListItem: View {
    @ObservedObject var mapMap: FetchedResults<MapMap>.Element
    @EnvironmentObject var backgroundMapDetails: BackgroundMapDetailsM
    
    var body: some View {
        HStack {
            AnyView(mapMap.getMap(.thumbnail))
                .mapMapListItemThumbnail()
            VStack(alignment: .leading) {
                Text(mapMap.mapMapName ?? "Unknown name")
                    .font(.title3)
                    .padding(.vertical, 7)
                    .foregroundStyle(.primary)
                    Text("Latitude: ") +
                    Text("\(mapMap.coordinates.latitude.wholeDegrees)º \(mapMap.coordinates.latitude.minutes)' \(mapMap.coordinates.latitude.seconds)'' ")
                        .fontWidth(.condensed)
                    Text("Longitude: ") +
                    Text("\(mapMap.coordinates.longitude.wholeDegrees)º \(mapMap.coordinates.longitude.minutes)' \(mapMap.coordinates.longitude.seconds)'' ")
                        .fontWidth(.condensed)
            }
            .foregroundStyle(.secondary)
            Spacer()
        }
    }
}
