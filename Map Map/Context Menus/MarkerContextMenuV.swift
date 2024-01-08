//
//  MarkerContextMenuV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/20/23.
//

import MapKit
import SwiftUI

/// Context menu for Markers
struct MarkerContextMenuV: View {
    /// Details about the background map being plotted on.
    @Environment(BackgroundMapDetailsM.self) private var backgroundMapDetails
    /// Current managed object context.
    @Environment(\.managedObjectContext) private var moc
    /// Marker being interacted with.
    @ObservedObject var marker: FetchedResults<Marker>.Element
    /// Action to take when Marker is deleted.
    var onDelete: (() -> Void)?
    
    var body: some View {
        Button(role: .destructive) {
            deleteMarker()
        } label: {
            Label("Delete Marker", systemImage: "trash.fill")
        }
        
        Button {
            marker.shown.toggle()
            try? moc.save()
        } label: {
            if marker.shown { Label("Hide Marker", systemImage: "eye.fill") }
            else { Label("Show Marker", systemImage: "eye.slash.fill") }
        }
        
        Button {
            backgroundMapDetails.moveMapCameraTo(marker: marker)
            marker.isEditing = true
        } label: {
            Label("Edit Marker", systemImage: "pencil")
        }
        
        Button {
            let placemark = MKPlacemark(coordinate: marker.coordinates)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.openInMaps(launchOptions: [ MKLaunchOptionsMapCenterKey: marker.coordinates ])
        } label: {
            Label("Open in Maps", systemImage: "map.fill")
        }
    }
    
    /// Delete marker and run closure code.
    func deleteMarker() {
        if let onDelete = onDelete {
            onDelete()
        }
        moc.delete(marker)
        try? moc.save()
    }
}
