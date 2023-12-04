//
//  MarkerListItemV.swift
//  Map Map
//
//  Created by Ben Roberts on 12/3/23.
//

import SwiftUI

struct MarkerListItemV: View {
    @ObservedObject var marker: FetchedResults<Marker>.Element
    @Environment(\.locationDisplayMode) var displayType
    let size: CGFloat = 30
    var body: some View {
        HStack {
            if let markerName = marker.name {
                MarkerV(marker: marker)
                    .frame(width: 30)
                    .padding()
                VStack {
                    Text(markerName)
                    MapMapListCoordsV(coordinates: marker.coordinates)
                    Text("test")
                }
            }
        }
    }
}
