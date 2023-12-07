//
//  DoneButtonV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/9/23.
//

import SwiftUI

/// Basic done button.
struct DoneButton: View {
    var enabled: Bool = true
    var action: () -> Void = { }
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            Text("Done")
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(.blue.opacity(enabled ? 1 : 0.5))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        })
        .disabled(!enabled)
    }
}

#Preview {
    VStack {
        Spacer()
        DoneButton(enabled: false)
        DoneButton(enabled: true)
    }
}
