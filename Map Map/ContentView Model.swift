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
    
    /// Handles drag and drop of images from outside of Map Map.
    /// - Parameter providers: All arguments given from drag and drop.
    /// - Returns: Success boolean.
    func dropImage(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first
        else { return false }
        if !provider.hasItemConformingToTypeIdentifier("public.image") { return false }
        _ = provider.loadObject(ofClass: UIImage.self) { image, _ in
            guard let image = image as? UIImage
            else { return }
            DispatchQueue.main.async { _ = MapMap(uiImage: image, moc: moc) }
        }
        return true
    }
}
