//
//  UnknownFileTypeVModifier.swift
//  Map Map
//
//  Created by Ben Roberts on 3/23/24.
//

import SwiftUI

struct UnknownImageTypeVModifier: ViewModifier {
    /// Boolean to control if the alert is shown
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .alert("File Not Permitted", isPresented: $isPresented) {
                Button("Ok", role: .cancel) { self.isPresented = false }
            } message: {
                Text("We're not sure what kind of file this is. Import only PDFs, JPEGs, and PNGs.")
            }
    }
}

extension View {
    /// An alert specific to telling the user that the image type is invalid.
    /// - Parameters:
    ///   - cancelAction: What to do when the action is cancelled.
    /// - Returns: This view with an alert attached
    func unknownImageType(isPresented: Binding<Bool>) -> some View {
        modifier(UnknownImageTypeVModifier(isPresented: isPresented))
    }
}
