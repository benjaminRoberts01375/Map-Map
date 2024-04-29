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
        @Environment(\.managedObjectContext) private var moc
        @Binding var viewModel: ViewModel
        
        var body: some View {
            VStack {
                HStack {
                    TextField("Map Map name", text: $viewModel.workingName)
                        .padding(.all, 5)
                        .background(Color.gray.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(width: 205)
                    AnyView(viewModel.actionButtons())
                }
                HStack {
                    // Done
                    Button(
                        action: { viewModel.save() },
                        label: { Text("Done").bigButton(backgroundColor: .blue) }
                    )
                    // Cancel
                    Button {
                        if viewModel.editing.isSetup { moc.reset() }
                        else { moc.delete(viewModel.editing) }
                        viewModel.editing.endEditing()
                    } label: {
                        Text("Cancel")
                            .bigButton(backgroundColor: viewModel.editing.isSetup ? .gray : .red)
                    }
                    // Delete
                    if viewModel.editing.isSetup {
                        Button {
                            viewModel.editing.endEditing()
                            moc.delete(viewModel.editing)
                            try? moc.save()
                        } label: {
                            Text("Delete")
                                .bigButton(backgroundColor: .red)
                        }
                    }
                }
            }
        }
    }
}
