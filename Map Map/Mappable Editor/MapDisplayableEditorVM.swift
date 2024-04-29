//
//  MapDisplayableEditorVM.swift
//  Map Map
//
//  Created by Ben Roberts on 4/29/24.
//

import CoreData
import SwiftUI

extension MapDisplayableEditorV {
    @Observable
    final class ViewModel {
        var workingName: String
        var actionButtons: () -> any View
        var additionalSaveAction: () -> Void
        var editing: any MapDisplayable & ListItem & EditableDataBlock & NSManagedObject
        
        init(
            actionButtons: @escaping () -> any View,
            additionalSaveAction: @escaping () -> Void,
            editing: any MapDisplayable & ListItem & EditableDataBlock & NSManagedObject
        ) {
            self.workingName = editing.displayName
            self.actionButtons = actionButtons
            self.additionalSaveAction = additionalSaveAction
            self.editing = editing
        }
        
        /// Save changes done from editing.
        func save() {
            editing.displayName = workingName
            additionalSaveAction()
            if !editing.isSetup { editing.isSetup = true }
            editing.endEditing()
            try? editing.managedObjectContext?.save()
        }
        
        /// Rollback changes from the editor.
        func cancel() {
            if editing.isSetup { editing.managedObjectContext?.reset() }
            else { editing.managedObjectContext?.delete(editing) }
            editing.endEditing()
        }
    }
}
