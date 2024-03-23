//
//  UnableToReadPDFVModifier.swift
//  Map Map
//
//  Created by Ben Roberts on 3/23/24.
//

import SwiftUI

struct UnableToReadPDFVModifier: ViewModifier {
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
    func unableToReadPDF(isPresented: Binding<Bool>) -> some View {
        modifier(UnableToReadPDFVModifier(isPresented: isPresented))
    }
}
