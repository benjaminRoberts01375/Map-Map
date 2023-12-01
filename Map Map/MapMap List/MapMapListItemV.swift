//
//  CompactMapListItemV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/23/23.
//

import SwiftUI

struct MapMapListItemV: View {
    @ObservedObject var mapMap: FetchedResults<MapMap>.Element
    @EnvironmentObject var backgroundMapDetails: BackgroundMapDetailsM
    @Environment(\.locationDisplayMode) var displayType
    let mapMapSize: CGFloat = 100
    let cornerRadius: CGFloat = 10
    
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
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius / 2))
                    .frame(minWidth: mapMapSize, idealWidth: mapMapSize, maxWidth: mapMapSize, minHeight: mapMapSize / 2, maxHeight: mapMapSize)
                    .background(.thickMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
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