//
//  BulletPointListV.swift
//  Map Map
//
//  Created by Ben Roberts on 3/22/24.
//

import SwiftUI

extension StoreV {
    /// Bullet points for why to get the Explorer package.
    struct BulletPointListV: View {
        var body: some View {
            ScrollView {
                VStack(spacing: 25) {
                    BulletPointV(
                        icon: "location.north.line.fill",
                        color: .red,
                        title: "GPS Maps",
                        description: "Create custom maps with GPS, and get real-time stats about your hike."
                    )
                    BulletPointV(
                        icon: "arrow.triangle.branch",
                        color: .brown,
                        title: "Trail Division",
                        description: "Divide your GPS Map into branches to match the trails."
                    )
                    BulletPointV(
                        icon: "app.badge.checkmark",
                        color: .mapMapPrimary,
                        title: "Future Development",
                        description: "Help fund future development, and get features beyond BYO map."
                    )
                }
                .padding(.horizontal)
            }
        }
    }
}
