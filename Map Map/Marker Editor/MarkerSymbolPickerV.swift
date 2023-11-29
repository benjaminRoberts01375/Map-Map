//
//  MarkerSymbolPickerV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/28/23.
//

import SwiftUI

struct MarkerSymbolPickerV: View {
    private let thumbnailImages: [String] = Mirror(reflecting: AvailableThumbnailImagesM()).children.sorted { $0.label! < $1.label! }.map { $0.value as! String }
    @ObservedObject var marker: FetchedResults<Marker>.Element
    
    var body: some View {
        ScrollView {
            Color.clear
                .frame(height: 10)
            WHStack {
                ForEach(thumbnailImages, id: \.self) { symbol in
                    Button {
                        marker.thumbnailImage = symbol
                    } label: {
                        MarkerSymbolPickerItemV(symbol: symbol, backgroundColor: marker.backgroundColor)
                            .frame(width: 45, height: 45)
                            .padding()
                            .background {
                                if marker.thumbnailImage == symbol {
                                    Color.lightGray
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                    }
                }
            }
            Color.clear
                .frame(height: 10)
        }
        .frame(width: 335, height: 300)
    }
}
