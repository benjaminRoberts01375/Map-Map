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
    @Binding var screenSpaceMarkerLocations: [Marker : CGPoint]
    let marker: FetchedResults<Marker>.Element
    
    var body: some View {
        Button(role: .destructive) {
            self.screenSpaceMarkerLocations.removeValue(forKey: marker)
            moc.delete(marker)
            try? moc.save()
        } label: {
            Label("Delete Marker", systemImage: "trash.fill")
        }
        
        Button {
            let distance: Double = 6000
            if let rotation = marker.lockRotationAngleDouble {
                withAnimation {
                    backgroundMapDetails.mapCamera = .camera(MapCamera(centerCoordinate: marker.coordinates, distance: distance, heading: -rotation))
                }
            }
            else {
                withAnimation {
                    backgroundMapDetails.mapCamera = .camera(MapCamera(centerCoordinate: marker.coordinates, distance: distance, heading: 0))
                }
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
