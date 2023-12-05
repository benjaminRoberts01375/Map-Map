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
    let markerSize: CGFloat = 30
    var body: some View {
        HStack(spacing: 0) {
            if let markerName = marker.name {
                MarkerV(marker: marker)
                    .frame(width: markerSize)
                    .padding(.trailing)
                VStack(alignment: .leading) {
                    Text(markerName)
                    MapMapListCoordsV(coordinates: marker.coordinates)
                }
            }
            Spacer(minLength: 0)
        }
        .opacity(marker.shown ? 1 : 0.5)
    }
}
