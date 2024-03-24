//
//  MeasurementEditorVM.swift
//  Map Map
//
//  Created by Ben Roberts on 3/24/24.
//

import SwiftUI

extension MeasurementEditorV {
    @Observable
    final class ViewModel {
        @ObservationIgnored @Binding var editor: Editor
        
        init(editor: Binding<Editor>) { self._editor = editor }
    }
}
