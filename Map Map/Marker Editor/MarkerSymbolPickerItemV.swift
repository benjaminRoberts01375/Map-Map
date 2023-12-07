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
    /// Foreground/accent color of the symbol.
    let foregroundColor: Color
    
    /// Create and render an SFSymbol for selection.
    /// - Parameters:
    ///   - symbol: Symbol to render.
    ///   - backgroundColor: Background color of the symbol.
    init(symbol: String, backgroundColor: Color) {
        self.symbol = symbol
        self.backgroundColor = backgroundColor
        self.foregroundColor = Marker.calculateForgroundColor(color: backgroundColor)
    }
    
    var body: some View {
        Circle()
            .foregroundStyle(backgroundColor)
            .shadow(color: .primary.opacity(0.5), radius: 3)
            .overlay {
                Image(systemName: symbol)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(foregroundColor)
                    .scaleEffect(0.6)
            }
    }
}

#Preview {
    MarkerSymbolPickerItemV(symbol: "map", backgroundColor: .red)
}
