//
//  MarkerSymbolPickerItemV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/28/23.
//

import SwiftUI

struct MarkerSymbolPickerItemV: View {
    let symbol: String
    let backgroundColor: Color
    let foregroundColor: Color
    
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
