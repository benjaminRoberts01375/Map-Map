//
//  LocationNotAlwaysVModifier.swift
//  Map Map
//
//  Created by Ben Roberts on 3/15/24.
//

import SwiftUI

struct LocationNotAlwaysVModifier: ViewModifier {
    /// Control the presentation of the alert.
    @Binding var isPresented: Bool
    /// Action to take when cancel button is pressed.
    var cancelAction: () -> Void
    
    func body(content: Content) -> some View {
        content
            .alert("Location not available", isPresented: $isPresented) {
                Button("Cancel", role: .cancel) { cancelAction() }
                Button("Settings") {
                    guard let settingsURL = URL(string: UIApplication.openSettingsURLString)
                    else { return }
                    UIApplication.shared.open(settingsURL)
                    isPresented = false
                }
                .keyboardShortcut(.defaultAction)
            } message: {
                Text("""
                Looks like Map Map can't ever see your location. \
                GPS Maps need your location to trace out where you go. You can either not make a GPS Map, or edit Map Map's settings.
                """)
            }
    }
}

extension View {
    func locationNotAlwaysAvailable(isPresented: Binding<Bool>, cancelAction: @escaping () -> Void) -> some View {
        modifier(LocationNotAlwaysVModifier(isPresented: isPresented, cancelAction: cancelAction))
    }
}
