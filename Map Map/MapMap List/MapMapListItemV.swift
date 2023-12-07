//
//  CompactMapListItemV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/23/23.
//

import SwiftUI

struct MapMapListItemV: View {
    @ObservedObject var mapMap: FetchedResults<MapMap>.Element
    @Environment(\.locationDisplayMode) var displayType
    private let mapMapSize: CGFloat = 100
    private let cornerRadius: CGFloat = 10
    
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
                    .frame(
                        minWidth: mapMapSize,
                        idealWidth: mapMapSize,
                        maxWidth: mapMapSize,
                        minHeight: mapMapSize / 2,
                        maxHeight: mapMapSize
                    )
                    .background(.thickMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .padding(.trailing)
                MapMapListCoordsV(coordinates: mapMap.coordinates)
                Spacer(minLength: 0)
            }
        }
        .opacity(mapMap.shown ? 1 : 0.5)
    }
}
