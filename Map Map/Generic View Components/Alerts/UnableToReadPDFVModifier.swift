//
//  UnableToReadPDFVModifier.swift
//  Map Map
//
//  Created by Ben Roberts on 3/23/24.
//

import SwiftUI

struct UnableToReadPDFVModifier: ViewModifier {
    /// Boolean to control if the alert is shown.
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .alert("File Not Readable", isPresented: $isPresented) {
                Button("Ok", role: .cancel) { self.isPresented = false }
            } message: {
                Text("We're not able to read the PDF.")
            }
    }
}

extension View {
    /// An alert specific to telling the user a PDF could not be read.
    /// - Parameters:
    ///   - isPresented: Boolean to control if the alert is shown.
    /// - Returns: This view with an alert attached
    func unableToReadPDF(isPresented: Binding<Bool>) -> some View {
        modifier(UnableToReadPDFVModifier(isPresented: isPresented))
    }
}
