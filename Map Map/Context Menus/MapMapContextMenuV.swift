//
//  MapMapContextMenuV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/30/23.
//

import MapKit
import SwiftUI

/// Context menu for MapMaps
struct MapMapContextMenuV: View {
    /// Details about the map being plotted on.
    @Environment(MapDetailsM.self) private var mapDetails
    /// Current managed object context.
    @Environment(\.managedObjectContext) private var moc
    /// MapMap being interacted with.
    @ObservedObject var mapMap: FetchedResults<MapMap>.Element
    
    var body: some View {
        Button {
            mapDetails.moveMapCameraTo(item: mapMap)
            mapMap.isEditing = true
        } label: {
            Label("Edit Map Map", systemImage: "pencil")
        }
        
        Button {
            mapMap.shown.toggle()
            try? moc.save()
        } label: {
            if mapMap.shown { Label("Hide Map Map", systemImage: "eye.fill") }
            else { Label("Show Map Map", systemImage: "eye.slash.fill") }
        }
        if !mapMap.unwrappedMarkers.isEmpty {
            Divider()
            DeleteMapMapV(mapMap)
            
            Button(role: .destructive) {
                for marker in mapMap.unwrappedMarkers { moc.delete(marker) }
                try? moc.save()
            } label: {
                Label("Delete Markers", systemImage: "trash.fill")
            }
            
            Button(role: .destructive) {
                for marker in mapMap.unwrappedMarkers { moc.delete(marker) }
                moc.delete(mapMap)
                try? moc.save()
            } label: {
                Label("Delete Map Map and Markers", systemImage: "trash.fill")
            }
        }
        else { DeleteMapMapV(mapMap) }
    }
    
    private struct DeleteMapMapV: View {
        /// Current managed object context.
        @Environment(\.managedObjectContext) private var moc
        /// MapMap being interacted with.
        @ObservedObject var mapMap: FetchedResults<MapMap>.Element
        
        init(_ mapMap: MapMap) { self.mapMap = mapMap }
        
        var body: some View {
            Button(role: .destructive) {
                moc.delete(mapMap)
                try? moc.save()
            } label: {
                Label("Delete Map Map", systemImage: "trash.fill")
            }
        }
    }
}
