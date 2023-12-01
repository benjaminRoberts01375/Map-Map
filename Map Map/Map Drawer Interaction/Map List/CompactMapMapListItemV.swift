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
    @Environment(\.locationDisplayMode) var displayType
    
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
                MapMapV(mapMap: mapMap, mapType: .thumbnail)
                    .mapMapListItemThumbnail()
                    .padding(.trailing)
                ViewThatFits {
                    VStack(alignment: .leading) {
                        Text("Latitude: ") +
                        Text(displayType.degreesToString(latitude: mapMap.coordinates.latitude))
                            .fontWidth(.condensed)
                        Text("Longitude: ") +
                        Text(displayType.degreesToString(longitude: mapMap.coordinates.longitude))
                            .fontWidth(.condensed)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Latitude: ")
                        Text(displayType.degreesToString(latitude: mapMap.coordinates.latitude))
                            .fontWidth(.condensed)
                        Text("Longitude: ")
                        Text(displayType.degreesToString(longitude: mapMap.coordinates.longitude))
                            .fontWidth(.condensed)
                    }
                }
                .foregroundStyle(.secondary)
                Spacer(minLength: 0)
            }
        }
    }
}
