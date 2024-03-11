//
//  Color.swift
//  Map Map
//
//  Created by Ben Roberts on 3/10/24.
//

import SwiftUI

extension Color {
    /// A white or black color based on the lumanence of this color.
    var contrastColor: Color {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        _ = UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        if red * 0.299 + green * 0.587 + blue * 0.114 > 0.5 { // Is a light color
            return .black
        }
        return .white
    }
}
