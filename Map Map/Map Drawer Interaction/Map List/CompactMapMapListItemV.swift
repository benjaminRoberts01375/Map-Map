//
//  CompactMapListItemV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/23/23.
//

import SwiftUI

struct CompactMapListItem: View {
    @ObservedObject var mapMap: FetchedResults<MapMap>.Element
    @EnvironmentObject var backgroundMapDetails: BackgroundMapDetailsM
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Spacer()
                Text(mapMap.mapMapName ?? "Unknown name")
                    .font(.title3)
                    .padding(.bottom, 7)
                Spacer()
            }
            HStack {
                AnyView(mapMap.getMap(.thumbnail))
                    .mapMapListItemThumbnail()
                VStack(alignment: .leading) {
                    if let coordinates = mapMap.coordinates {
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
    }
}
