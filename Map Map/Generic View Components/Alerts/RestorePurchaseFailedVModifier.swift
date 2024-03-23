//
//  RestorePurchaseFailed.swift
//  Map Map
//
//  Created by Ben Roberts on 3/22/24.
//

import SwiftUI

fileprivate struct InAppPurchaseFailed: ViewModifier {
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .alert("Not able to restore purchases", isPresented: $isPresented) {
                Button("Ok", role: .cancel) { isPresented = false }
                    .keyboardShortcut(.defaultAction)
            } message: {
                Text("You may have never become an explorer, or you do not have an internet connection.")
            }
    }
}

extension View {
    func inAppPurchaseFailed(isPresented: Binding<Bool>) -> some View {
        modifier(InAppPurchaseFailed(isPresented: isPresented))
    }
}
