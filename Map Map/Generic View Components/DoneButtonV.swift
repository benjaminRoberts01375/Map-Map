//
//  DoneButtonV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/9/23.
//

import SwiftUI

/// Basic done button.
struct DoneButton: View {
    /// Allow activating.
    var enabled: Bool = true
    /// What to do when button is pressed. Default is nothing.
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
