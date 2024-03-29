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
                Button("Ok", role: .cancel) { cancelAction() }
                Button("Settings") {
                    guard let settingsURL = URL(string: UIApplication.openSettingsURLString)
                    else { return }
                    UIApplication.shared.open(settingsURL)
                    isPresented = false
                }
                .keyboardShortcut(.defaultAction)
            } message: {
                Text("""
                Looks like Map Map can't see your location when the app is closed. \
                Make sure to leave Map Map open while making a GPS Map, or edit Map Map's settings.
                """)
            }
    }
}

extension View {
    /// An alert specific to telling the user that GPS Maps need always location
    /// and allow easy access to settings to change it.
    /// - Parameters:
    ///   - isPresented: Boolean to control if the alert is shown.
    ///   - cancelAction: What to do when the action is cancelled.
    /// - Returns: This view with an alert attached
    func locationNotAlwaysAvailable(isPresented: Binding<Bool>, cancelAction: @escaping () -> Void) -> some View {
        modifier(LocationNotAlwaysVModifier(isPresented: isPresented, cancelAction: cancelAction))
    }
}
