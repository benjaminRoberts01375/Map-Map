//
//  MapInfoV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/15/23.
//

import SwiftUI

struct MapInfo: View {
    @ObservedObject var photo: FetchedResults<MapPhoto>.Element
    @EnvironmentObject var mapDetails: MapDetailsM
    
    var body: some View {
        Text(photo.mapName ?? "Unknown name")
            .padding(.vertical)
        Text("Longitude: \(photo.longitude!)º")
            .foregroundStyle(.secondary)
        Text("Latitude: \(photo.latitude!)º")
            .foregroundStyle(.secondary)
    }
}
