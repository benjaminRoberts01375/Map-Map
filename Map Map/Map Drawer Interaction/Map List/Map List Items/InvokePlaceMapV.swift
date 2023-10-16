//
//  InvokePlaceMapV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/15/23.
//

import SwiftUI

struct InvokePlaceMap: View {
    @ObservedObject var photo: FetchedResults<MapPhoto>.Element
    @EnvironmentObject var mapDetails: MapDetailsM
    
    var body: some View {
        Text(photo.mapName ?? "Unknown name")
            .padding(.vertical)
        Button {
            photo.isPlacing = true
            mapDetails.allowsInteraction = false
//                        photo.coordinates = mapDetails.position
        } label: {
            Text("Add to map")
        }
    }
}
