//
//  MapItemV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/10/23.
//

import SwiftUI

struct MapListItem: View {
    @ObservedObject var photo: FetchedResults<MapPhoto>.Element
    @EnvironmentObject var mapDetails: MapDetailsM
    
    var body: some View {
        HStack {
            AnyView(photo.getMap(.thumbnail))
                .mapListItemThumbnail()
            VStack(alignment: .leading) {
                Text(photo.mapName ?? "Unknown name")
                    .font(.title3)
                    .padding(.vertical, 7)
                    .foregroundStyle(.primary)
                if let coordinates = photo.coordinates {
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
