//
//  LocationNeverAvailableVModifier.swift
//  Map Map
//
//  Created by Ben Roberts on 3/15/24.
//

import SwiftUI

struct LocationNeverAvailableVModifier: ViewModifier {
    /// Control the presentation of the alert.
    @Binding var isPresented: Bool
    /// Action to take when cancel button is pressed.
    var cancelAction: () -> Void
    
    func body(content: Content) -> some View {
        content
            .alert("Don't close Map Map!", isPresented: $isPresented) {
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
    /// An alert specific to telling the user that Map Map can never access their location,
    /// and provides them with the means to edit settings.
    /// - Parameters:
    ///   - isPresented: Boolean to control if the alert is shown.
    ///   - cancelAction: What to do when the action is cancelled.
    /// - Returns: This view with an alert attached
    func locationNeverAvailable(isPresented: Binding<Bool>, cancelAction: @escaping () -> Void) -> some View {
        modifier(LocationNeverAvailableVModifier(isPresented: isPresented, cancelAction: cancelAction))
    }
}
