//
//  BulletPointV.swift
//  Map Map
//
//  Created by Ben Roberts on 3/22/24.
//

import SwiftUI

extension StoreV.BulletPointListV {
    struct BulletPointV: View {
        let icon: String
        let color: Color
        let title: String
        let description: String
        private let size: CGFloat = 35
        
        var body: some View {
            HStack(alignment: .center) {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .padding(.horizontal)
                    .foregroundStyle(color)
                    .accessibilityHidden(true)
                VStack(alignment: .leading) {
                    Text(title)
                        .bold()
                    Text(description)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
    }

}
