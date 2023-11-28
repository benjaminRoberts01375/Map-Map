//
//  MarkerSymbolPickerItemV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/28/23.
//

import SwiftUI

struct MarkerSymbolPickerItemV: View {
    let symbol: String
    
    var body: some View {
        Image(systemName: symbol)
            .resizable()
            .scaledToFit()
            .foregroundStyle(.white)
    }
}
