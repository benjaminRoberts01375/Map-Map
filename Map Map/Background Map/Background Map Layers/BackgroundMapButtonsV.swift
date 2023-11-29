//
//  BackgroundMapButtonsV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/19/23.
//

import MapKit
import SwiftUI

struct BackgroundMapButtonsV: View {
    @FetchRequest(sortDescriptors: []) var markers: FetchedResults<Marker>
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var backgroundMapDetails: BackgroundMapDetailsM
    @State var markerButton: MarkerButtonType = .add
    @Binding var markerPositions: [Marker : CGPoint]
    @Binding var displayType: LocationDisplayMode
    let screenSize: CGSize
    let mapScope: Namespace.ID
    
    enum MarkerButtonType: Equatable {
        case add
        case delete(Marker)
    }
    
    var body: some View {
        HStack(alignment: .top) {
            VStack {
                BackgroundMapHudV(rawDisplayType: $displayType)
                MapScaleView(scope: mapScope)
            }
            VStack {
                MapUserLocationButton(scope: mapScope)
                    .background(.thickMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                
                switch markerButton {
                case .add:
                    Button {
                        let _ = Marker(coordinates: backgroundMapDetails.position, insertInto: moc)
                        try? moc.save()
                    } label: {
                        Image(systemName: "mappin.and.ellipse")
                            .mapButton()
                    }
                case .delete(let marker):
                    Button {
                        moc.delete(marker)
                        try? moc.save()
                    } label: {
                        Image(systemName: "mappin.slash")
                            .mapButton()
                    }
                }
            }
        }
        .animation(.easeInOut, value: markerButton)
        .mapScope(mapScope)
        .onChange(of: backgroundMapDetails.position) { checkOverMarker() }
    }
    
    func checkOverMarker() {
        for marker in markers {
            if let markerPos = markerPositions[marker] {
                let xComponent = abs(markerPos.x - screenSize.width  / 2)
                let yComponent = abs(markerPos.y - screenSize.height / 2)
                let distance = sqrt(pow(xComponent, 2) + pow(yComponent, 2))
                if distance < BackgroundMapPointsV.iconSize / 2 {
                    markerButton = .delete(marker)
                    return
                }
            }
        }
        switch markerButton {
        case .add:
            break
        default:
            markerButton = .add
        }
    }
}
