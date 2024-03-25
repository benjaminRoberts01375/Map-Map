//
//  MapMapExplorerTitleV.swift
//  Map Map
//
//  Created by Ben Roberts on 3/22/24.
//

import SwiftUI

extension StoreV {
    /// Display explorer text and MapMap icon.
    struct MapMapExplorerTitleV: View {
        var body: some View {
            VStack {
                Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .accessibilityHidden(true)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .shadow(radius: 10)
                Text("Map Map")
                    .font(.system(size: 70).bold())
                Text("- Explorer -")
                    .font(.system(size: 50).bold())
                    .scaleEffect(x: 0.9)
                
            }
        }
    }
}
