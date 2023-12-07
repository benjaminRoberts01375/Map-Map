//
//  MapMapContextMenuV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/30/23.
//

import MapKit
import SwiftUI

struct MapMapContextMenuV: View {
    @Environment(BackgroundMapDetailsM.self) private var backgroundMapDetails
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var mapMap: FetchedResults<MapMap>.Element
    
    var body: some View {
        Button(role: .destructive) {
            moc.delete(mapMap)
            try? moc.save()
        } label: {
            Label("Delete Map Map", systemImage: "trash.fill")
        }
        
        Button {
            backgroundMapDetails.moveMapCameraTo(mapMap: mapMap)
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
    }
}
