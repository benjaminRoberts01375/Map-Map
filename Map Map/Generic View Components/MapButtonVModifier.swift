//
//  AddMarkerV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/19/23.
//

import SwiftUI

/// Button to overlay on top of the map.
struct MapButtonV: ViewModifier {
    /// The current color scheme of the device (Ex. Dark vs Light mode)
    @Environment(\.colorScheme) var colorScheme
    /// Dimensions of the button.
    private let size: CGFloat = 45
    /// Is currently being used.
    let active: Bool
    /// Calculated foreground color.
    var foregroundColor: Color {
        if active {
            switch colorScheme {
            case .dark: return Color(red: 0.13, green: 0.16, blue: 0.17)
            default: return .white
            }
        }
        return .blue
    }
    
    func body(content: Content) -> some View {
        content
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundStyle(foregroundColor)
            .background { if active { Color.blue } }
            .background(.thickMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

extension View {
    /// Button to overlay on top of the map.
    func mapButton(active: Bool = false) -> some View {
        modifier(MapButtonV(active: active))
    }
}
