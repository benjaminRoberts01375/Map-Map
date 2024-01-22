//
//  StickToMapVModifier.swift
//  Map Map
//
//  Created by Ben Roberts on 1/22/24.
//

import SwiftUI

extension View {
    func stickToMap(rotation: Angle, width: CGFloat) -> some View {
        self
        .frame(width: width)
        .rotationEffect(rotation)
        .offset(y: -7)
    }
}
