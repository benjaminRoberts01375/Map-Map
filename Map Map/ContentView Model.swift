//
//  ContentView Model.swift
//  Map Map
//
//  Created by Ben Roberts on 4/23/24.
//

import SwiftUI

extension ContentView {
    @Observable
    final class ViewModel {
        /// Information to display in a Toast notification.
        var toastInfo: ToastInfo = ToastInfo()
        /// Track if a drag and drop action may occur on this view.
        var dragAndDropTargeted: Bool = false
        /// Control the opacity of the dark shade overlay.
        var shadeOpacity: CGFloat = 0
        /// Object being edited
        var editing: Editor = .nothing
    }
}
