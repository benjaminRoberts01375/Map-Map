//
//  MarkerListItemV.swift
//  Map Map
//
//  Created by Ben Roberts on 12/3/23.
//

import SwiftUI

/// An uninteractive Marker list item.
struct MarkerListItemV: View {
    /// Marker to derrive the list item from.
    @ObservedObject var marker: FetchedResults<Marker>.Element
    /// How to render coordinates from environment.
    @Environment(\.locationDisplayMode) private var displayType
    /// Size of the Marker within the list.
    private let markerSize: CGFloat = 30
    
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
