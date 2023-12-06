//
//  BackgroundMapButtonsV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/19/23.
//

import MapKit
import SwiftUI

struct BackgroundMapButtonsV: View {
    @FetchRequest(sortDescriptors: []) var mapMaps: FetchedResults<MapMap>
    @FetchRequest(sortDescriptors: []) var markers: FetchedResults<Marker>
    @Environment(\.managedObjectContext) var moc
    @Environment(ScreenSpacePositionsM.self) var screenSpacePositions
    @Environment(BackgroundMapDetailsM.self) var backgroundMapDetails
    @State var markerButton: MarkerButtonType = .add
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
                        addMarker()
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
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
            checkOverMarker()
        }
    }
    
    func checkOverMarker() {
        for marker in markers {
            if let markerPos = screenSpacePositions.markerPositions[marker] {
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
    
    func addMarker() {
        let newMarker = Marker(coordinates: backgroundMapDetails.position, insertInto: moc)
        let centerPoint: CGPoint = CGPoint(size: screenSize / 2)
        for mapMap in mapMaps {
            if let path = screenSpacePositions.generateMapMapRotatedBounds(mapMap: mapMap, backgroundMapRotation: backgroundMapDetails.rotation)?.cgPath, 
                path.contains(centerPoint) {
                newMarker.addToMapMap(mapMap)
            }
        }
        try? moc.save()
    }
}
