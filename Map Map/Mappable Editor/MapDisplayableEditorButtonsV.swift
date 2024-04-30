//
//  MapDisplayableButtons.swift
//  Map Map
//
//  Created by Ben Roberts on 4/29/24.
//

import CoreData
import SwiftUI

extension MapDisplayableEditorV {
    struct BottomButtonsV: View {
        @Binding var viewModel: ViewModel
        
        var body: some View {
            VStack {
                HStack {
                    TextField("Name", text: $viewModel.workingName)
                        .padding(.all, 5)
                        .background(Color.gray.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(width: 205)
                    ForEach(Array(viewModel.editorButtons.enumerated()), id: \.offset) { AnyView($1) }
                }
                HStack {
                    // Done
                    Button(
                        action: { viewModel.save() },
                        label: { Text("Done").bigButton(backgroundColor: .blue) }
                    )
                    // Cancel
                    Button(
                        action: { viewModel.cancel() },
                        label: { Text("Cancel").bigButton(backgroundColor: viewModel.editing.isSetup ? .gray : .red) }
                    )
                    // Delete
                    if viewModel.editing.isSetup {
                        Button(
                            action: { viewModel.delete() },
                            label: { Text("Delete").bigButton(backgroundColor: .red) }
                        )
                    }
                }
            }
        }
    }
}
