//
//  CompactMapListItemV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/23/23.
//

import SwiftUI

struct ListItemV: View {
    @ObservedObject var mapMap: FetchedResults<MapMap>.Element
    @EnvironmentObject var backgroundMapDetails: BackgroundMapDetailsM
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                Text(mapMap.mapMapName ?? "Unknown name")
                    .font(.title3)
                    .padding(.bottom, 7)
                Spacer(minLength: 0)
            }
            HStack(spacing: 0) {
                AnyView(mapMap.getMap(.thumbnail))
                    .mapMapListItemThumbnail()
                    .padding(.trailing)
                ViewThatFits {
                    VStack(alignment: .leading) {
                        Text("Latitude: ") +
                        Text("\(mapMap.coordinates.latitude.wholeDegrees)º \(mapMap.coordinates.latitude.minutes)' \(mapMap.coordinates.latitude.seconds)'' ")
                            .fontWidth(.condensed)
                        Text("Longitude: ") +
                        Text("\(mapMap.coordinates.longitude.wholeDegrees)º \(mapMap.coordinates.longitude.minutes)' \(mapMap.coordinates.longitude.seconds)'' ")
                            .fontWidth(.condensed)
                    }
                    .background(.red)
                    
                    VStack(alignment: .leading) {
                        Text("Latitude: ")
                        Text("\(mapMap.coordinates.latitude.wholeDegrees)º \(mapMap.coordinates.latitude.minutes)' \(mapMap.coordinates.latitude.seconds)'' ")
                            .fontWidth(.condensed)
                        Text("Longitude: ")
                        Text("\(mapMap.coordinates.longitude.wholeDegrees)º \(mapMap.coordinates.longitude.minutes)' \(mapMap.coordinates.longitude.seconds)'' ")
                            .fontWidth(.condensed)
                    }
                }
                .foregroundStyle(.secondary)
                Spacer(minLength: 0)
            }
        }
    }
}
