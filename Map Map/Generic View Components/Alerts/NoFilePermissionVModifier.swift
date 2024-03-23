//
//  NoFilePermissionVModifier.swift
//  Map Map
//
//  Created by Ben Roberts on 3/23/24.
//

import SwiftUI

struct NoFilePermissionVModifier: ViewModifier {
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
    func noFilePermission(isPresented: Binding<Bool>) -> some View {
        modifier(NoFilePermissionVModifier(isPresented: isPresented))
    }
}
