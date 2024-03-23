//
//  FileNotReadableVModifier.swift
//  Map Map
//
//  Created by Ben Roberts on 3/23/24.
//

import SwiftUI

struct FileNotReadableVModifier: ViewModifier {
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .alert("File Not Permitted", isPresented: $isPresented) {
                Button("Ok", role: .cancel) { self.isPresented = false }
            } message: {
                Text("We're not able to read the file.")
            }
    }
}

extension View {
    func fileNotReadable(isPresented: Binding<Bool>) -> some View {
        modifier(FileNotReadableVModifier(isPresented: isPresented))
    }
}

