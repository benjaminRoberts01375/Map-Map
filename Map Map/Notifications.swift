//
//  SavingNotification.swift
//  Map Map
//
//  Created by Ben Roberts on 11/15/23.
//

import NotificationCenter

/// An extension to the Notification Center system.
extension Notification.Name {
    /// Notification name to be sent when Core Data is saving data.
    public static let savingToastNotification = Notification.Name("SavingData")
    /// Notification name to be sent when a new Marker is added.
    public static let editedMarkerLocation = Notification.Name("NewMarker")
    /// Notification name to be sent when a Marker is being edited.
    public static let editingMarker = Notification.Name("EditingMarker")
}
