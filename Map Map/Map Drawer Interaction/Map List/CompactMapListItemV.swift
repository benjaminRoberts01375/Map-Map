//
//  CompactMapListItemV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/23/23.
//

import SwiftUI

struct CompactMapListItem: View {
    @ObservedObject var photo: FetchedResults<MapPhoto>.Element
    @EnvironmentObject var mapDetails: MapDetailsM
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Text(photo.mapName ?? "Unknown name")
                    .font(.title3)
                Spacer()
            }
            HStack {
                AnyView(photo.getMap(.thumbnail))
                    .mapListItemThumbnail()
                VStack(alignment: .leading) {
                    if let coordinates = photo.coordinates {
                        Text("Latitude: ")
                        Text("\(coordinates.latitude.wholeDegrees)º \(coordinates.latitude.minutes)' \(coordinates.latitude.seconds)'' ")
                            .fontWidth(.condensed)
                        Text("Longitude: ")
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
        .padding()
    }
}
