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
                if let coordinates = mapMap.coordinates {
                    Text("Latitude: ") +
                    Text("\(coordinates.latitude.wholeDegrees)º \(coordinates.latitude.minutes)' \(coordinates.latitude.seconds)'' ")
                        .fontWidth(.condensed)
                    Text("Longitude: ") +
                    Text("\(coordinates.longitude.wholeDegrees)º \(coordinates.longitude.minutes)' \(coordinates.longitude.seconds)'' ")
                        .fontWidth(.condensed)
                }
                else {
                    Text("Unknown location")
                }
            }
            .foregroundStyle(.secondary)
            Spacer()
        }
    }
}
