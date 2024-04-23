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
    
    /// Handle Notification Center notifications for when an `EditableDatablock` begins or ends editing.
    /// - Parameter notification: Notification Center notification to check.
    func editingDataBlock(notification: NotificationCenter.Publisher.Output) {
        if let editableData = notification.object as? MapMap {
            viewModel.editing = editableData.isEditing ? .mapMap(editableData) : .nothing
        }
        else if let editableData = notification.object as? GPSMap {
            viewModel.editing = editableData.isEditing ? .gpsMap(editableData) : .nothing
        }
        else if let editableData = notification.object as? Marker {
            viewModel.editing = editableData.isEditing ? .marker(editableData) : .nothing
        }
        else { viewModel.editing = .nothing }
    }
    
    /// Display a toast notification when saving large CD change.
    /// - Parameter notification: Notification to check against.
    func savingToastNotification(notification: NotificationCenter.Publisher.Output) {
        if let showing = notification.userInfo?["savingVal"] as? Bool {
            viewModel.toastInfo.showing = showing
        }
        if let info = notification.userInfo?["name"] as? String {
            viewModel.toastInfo.info = info
        }
    }
    
    /// Setup displaying tips.
    func tipSetup() {
        if !AddMapMapTip.discovered { // Update adding a Map Map tip
            Timer.scheduledTimer(withTimeInterval: 15, repeats: false) { _ in
                AddMapMapTip.discovered = true
            }
        }
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in // Update using the HUD tip
            Task { await UseHUDTip.count.donate() }
        }
    }
}
