//
//  MarkerSymbolPickerItemV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/28/23.
//

import SwiftUI

/// A single symbol to render.
struct MarkerSymbolPickerItemV: View {
    /// SFSymbol to render.
    let symbol: String
    /// Background/primary color of the symbol.
    let backgroundColor: Color
    
    /// Create and render an SFSymbol for selection.
    /// - Parameters:
    ///   - symbol: Symbol to render.
    ///   - backgroundColor: Background color of the symbol.
    init(symbol: String, backgroundColor: Color) {
        self.symbol = symbol
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        Circle()
            .foregroundStyle(backgroundColor)
            .shadow(color: .primary.opacity(0.5), radius: 3)
            .overlay {
                Image(systemName: symbol)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(backgroundColor.contrastColor)
                    .scaleEffect(0.6)
                    .accessibilityLabel("\(symbol) marker icon")
            }
    }
}

#Preview {
    MarkerSymbolPickerItemV(symbol: "map", backgroundColor: .red)
}
