//
//  GPSMapContextMenu.swift
//  Map Map
//
//  Created by Ben Roberts on 3/17/24.
//

import SwiftUI

struct GPSMapContextMenu: View {
    /// Current managed object context.
    @Environment(\.managedObjectContext) private var moc
    /// Details about the map being plotted on.
    @Environment(MapDetailsM.self) private var mapDetails
    /// GPS Map being interacted with
    @ObservedObject var gpsMap: GPSMap
    
    var body: some View {
        Button(role: .destructive) {
            moc.delete(gpsMap)
            try? moc.save()
        } label: {
            Label("Delete GPS Map", systemImage: "trash.fill")
        }
        
        Button {
            mapDetails.moveMapCameraTo(item: gpsMap)
            gpsMap.isEditing = true
        } label: {
            Label("Edit GPS Map", systemImage: "pencil")
        }
        
        Button {
            gpsMap.shown.toggle()
            try? moc.save()
        } label: {
            if gpsMap.shown { Label("Hide GPS Map", systemImage: "eye.fill") }
            else { Label("Show GPS Map", systemImage: "eye.slash.fill") }
        }
    }
}
