//
//  MapLabelVModifier.swift
//  Map Map
//
//  Created by Ben Roberts on 12/16/23.
//

import SwiftUI

struct MapLabelVModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    /// Control if the satellite map is shown.
    @AppStorage(UserDefaults.kShowSatelliteMap) var mapType = UserDefaults.dShowSatelliteMap
    private let shadowRadius: CGFloat = 8
    
    var foregroundColor: Color {
        if colorScheme == .dark || mapType { return .white }
        return .black
    }
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(foregroundColor)
            .shadow(color: foregroundColor == .white ? .black : .white, radius: shadowRadius)
    }
}

extension View {
    /// Standard modifier for text on the map.
    /// - Returns: Modified view.
    func mapLabel() -> some View {
        modifier(MapLabelVModifier())
    }
}
