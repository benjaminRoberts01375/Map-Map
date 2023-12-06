//
//  MarkerContextMenuV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/20/23.
//

import MapKit
import SwiftUI

struct MarkerContextMenuV: View {
    @EnvironmentObject var backgroundMapDetails: BackgroundMapDetailsM
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var marker: FetchedResults<Marker>.Element
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        Button(role: .destructive) {
            if let onDelete = onDelete {
                onDelete()
            }
            moc.delete(marker)
            try? moc.save()
        } label: {
            Label("Delete Marker", systemImage: "trash.fill")
        }
        
        Button {
            marker.shown.toggle()
            try? moc.save()
        } label: {
            if marker.shown { Label("Hide Marker", systemImage: "eye.fill") }
            else { Label("Show Marker" , systemImage: "eye.slash.fill") }
        }
        
        Button {
            let distance: Double = 6000
            withAnimation {
                backgroundMapDetails.mapCamera = .camera(MapCamera(centerCoordinate: marker.coordinates, distance: distance, heading: -(marker.lockRotationAngleDouble ?? 0)))
            }
            marker.isEditing = true
        } label: {
            Label("Edit Marker", systemImage: "pencil")
        }
        
        Button {
            let placemark = MKPlacemark(coordinate: marker.coordinates)
            let mapItem = MKMapItem(placemark: placemark)
            let launchOptions: [String : Any] = [
                MKLaunchOptionsMapCenterKey: marker.coordinates
            ]
            mapItem.openInMaps(launchOptions: launchOptions)
        } label: {
            Label("Open in Maps", systemImage: "map.fill")
        }
    }
}
