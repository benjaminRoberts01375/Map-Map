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
        @State var workingName: String
        var actionButtons: () -> any View
        var additionalSaveAction: () -> Void
        @Binding var editing: any MapDisplayable & ListItem & EditableDataBlock & NSManagedObject
        
        var body: some View {
            VStack {
                HStack {
                    TextField("Map Map name", text: $workingName)
                        .padding(.all, 5)
                        .background(Color.gray.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(width: 205)
                    AnyView(actionButtons())
                }
                HStack {
                    // Done
                    Button(
                        action: {
                            editing.displayName = workingName
                            additionalSaveAction()
                            if !editing.isSetup { editing.isSetup = true }
                            editing.endEditing()
                        },
                        label: { Text("Done").bigButton(backgroundColor: .blue) }
                    )
                    // Cancel
                    Button {
                        if editing.isSetup { moc.reset() }
                        else { moc.delete(editing) }
                        editing.endEditing()
                    } label: {
                        Text("Cancel")
                            .bigButton(backgroundColor: editing.isSetup ? .gray : .red)
                    }
                    // Delete
                    if editing.isSetup {
                        Button {
                            editing.endEditing()
                            moc.delete(editing)
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
