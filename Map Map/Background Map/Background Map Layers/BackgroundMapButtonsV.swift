//
//  BackgroundMapButtonsV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/19/23.
//

import MapKit
import SwiftUI

struct BackgroundMapButtonsV: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var backgroundMapDetails: BackgroundMapDetailsM
    
    let mapScope: Namespace.ID
    
    var body: some View {
        HStack(alignment: .top) {
            VStack {
                BackgroundMapHudV()
                MapScaleView(scope: mapScope)
            }
            VStack {
                MapUserLocationButton(scope: mapScope)
                    .background(.thickMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                Button {
                    let _ = Marker(coordinates: backgroundMapDetails.position, insertInto: moc)
                    try? moc.save()
                } label: {
                    Image(systemName: "mappin.and.ellipse")
                        .mapButton()
                }
            }
        }
        .mapScope(mapScope)
    }
}
