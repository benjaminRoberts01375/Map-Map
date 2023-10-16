//
//  PlaceMapV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/15/23.
//

import SwiftUI

struct PlaceMap: View {
    @ObservedObject var photo: FetchedResults<MapPhoto>.Element
    @EnvironmentObject var mapDetails: MapDetailsM
    
    var body: some View {
        Button {
            print("TODO: Save loc, rot, scale")
            photo.isPlacing = false
            mapDetails.allowsInteraction = true
        } label: {
            Text("Save")
                .bigButton(backgroundColor: .blue)
        }
        Button {
            photo.isPlacing = false
            mapDetails.allowsInteraction = true
        } label: {
            Text("Cancel")
                .bigButton(backgroundColor: .gray)
        }
    }
}
