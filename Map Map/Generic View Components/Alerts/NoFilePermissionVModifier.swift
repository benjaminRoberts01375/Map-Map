//
//  NoFilePermissionVModifier.swift
//  Map Map
//
//  Created by Ben Roberts on 3/23/24.
//

import SwiftUI

struct NoFilePermissionVModifier: ViewModifier {
    /// Boolean to control if the alert is shown.
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .alert("File Not Permitted", isPresented: $isPresented) {
                Button("Ok", role: .cancel) { self.isPresented = false }
            } message: {
                Text("""
                We're not able to get permission to open the file.
                """)
            }
    }
}

extension View {
    /// An alert specific to telling the user that Map Map cannot access this file.
    /// - Parameters:
    ///   - isPresented: Boolean to control if the alert is shown.
    /// - Returns: This view with an alert attached
    func noFilePermission(isPresented: Binding<Bool>) -> some View {
        modifier(NoFilePermissionVModifier(isPresented: isPresented))
    }
}
