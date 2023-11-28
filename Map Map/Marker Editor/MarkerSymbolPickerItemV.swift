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
    
    var body: some View {
        Circle()
            .foregroundStyle(backgroundColor)
            .overlay {
                Image(systemName: symbol)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white)
                    .scaleEffect(0.6)
            }
    }
}

#Preview {
    MarkerSymbolPickerItemV(symbol: "map", backgroundColor: .red)
}
