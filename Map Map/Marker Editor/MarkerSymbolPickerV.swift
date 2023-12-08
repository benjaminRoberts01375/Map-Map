//
//  MarkerSymbolPickerV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/28/23.
//

import SwiftUI

/// Displays symbols and allows for selection of a symbol for a Marker. Highlights currently selected symbol.
struct MarkerSymbolPickerV: View {
    /// All available marker symbols.
    private let thumbnailImages: [String] = Mirror(reflecting: AvailableThumbnailImagesM()).children.map { $0.value as? String ?? "" }
    /// Marker being edited.
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
                                    Color.highlightGray
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                    }
                }
            }
            Color.clear
                .frame(height: 10)
        }
    }
}
