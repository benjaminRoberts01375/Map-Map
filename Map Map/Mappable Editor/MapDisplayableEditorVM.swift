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
    }
}
