//
//  MarkerContextMenuV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/20/23.
//

import MapKit
import SwiftUI

struct MarkerContextMenuV: View {
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
    }
}
