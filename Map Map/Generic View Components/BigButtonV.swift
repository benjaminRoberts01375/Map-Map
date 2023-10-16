//
//  BigButtonV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/15/23.
//

import SwiftUI

struct BigButton: ViewModifier {
    let background: Color
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(.white)
            .frame(width: 100, height: 50)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

extension View {
    func bigButton(backgroundColor background: Color) -> some View {
        return modifier(BigButton(background: background))
    }
}
