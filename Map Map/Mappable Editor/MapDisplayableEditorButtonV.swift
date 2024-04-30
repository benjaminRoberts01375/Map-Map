//
//  MapDisplayableEditorButtonV.swift
//  Map Map
//
//  Created by Ben Roberts on 4/29/24.
//

import SwiftUI

extension MapDisplayableEditorV {
    struct EditorButton: View, Identifiable {
        let id = UUID()
        let systemImage: String
        let label: String
        let action: () -> Void
        
        var body: some View {
            Button {
                action()
            } label: {
                Image(systemName: systemImage)
                    .resizable()
                    .scaledToFit()
                    .accessibilityLabel(label)
                    .frame(width: 20, height: 20)
                    .padding(5)
                    .background(.gray)
                    .clipShape(Circle())
            }
        }
    }
}
