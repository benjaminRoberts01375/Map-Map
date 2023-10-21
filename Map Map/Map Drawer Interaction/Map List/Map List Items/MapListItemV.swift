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
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .frame(width: 100, height: 100)
                .background(.thickMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.vertical)
            Text(photo.mapName ?? "Unknown name")
                .padding(.vertical)
            Text("Longitude: \(photo.longitude!)º")
                .foregroundStyle(.secondary)
            Text("Latitude: \(photo.latitude!)º")
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
        }
    }
}
