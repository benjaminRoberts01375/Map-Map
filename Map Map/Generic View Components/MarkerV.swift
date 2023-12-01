//
//  MarkerV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/30/23.
//

import SwiftUI

struct MarkerV: View {
    @ObservedObject var marker: FetchedResults<Marker>.Element
    
    var body: some View {
        Circle()
            .fill(marker.backgroundColor)
            .overlay {
                marker.correctedThumbnailImage
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.6)
                    .foregroundStyle(marker.forgroundColor)
            }
            .ignoresSafeArea(.all)
    }
}
