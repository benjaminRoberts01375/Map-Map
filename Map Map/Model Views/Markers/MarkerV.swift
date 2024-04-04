//
//  MarkerV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/30/23.
//

import SwiftUI

struct MarkerV: View {
    /// Simple renderer for Markers.
    @ObservedObject var marker: FetchedResults<Marker>.Element
    /// Marker icon size.
    static let iconSize: CGFloat = 30
    
    var body: some View {
        Circle()
            .fill(marker.backgroundColor)
            .overlay {
                marker.renderedThumbnailImage
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.6)
                    .foregroundStyle(marker.backgroundColor.contrastColor)
            }
            .ignoresSafeArea(.all)
    }
}
