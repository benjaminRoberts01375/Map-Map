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
    @EnvironmentObject var backgroundMapDetails: BackgroundMapDetailsM
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
    
    func checkOverMapMap(mapMap: MapMap) -> Bool {
        guard let rect: CGRect = screenSpacePositions.mapMapPositions[mapMap]
        else { return false }
        
        let transform = CGAffineTransform(translationX: rect.midX - rect.width / 2, y: rect.midY - rect.height / 2)
            .rotated(by: (backgroundMapDetails.rotation - Angle(degrees: mapMap.mapMapRotation)).radians)
            .translatedBy(x: -rect.midX, y: -rect.midY)
        
        let offset: CGFloat = 50
        
        // Calculate rotated points
        let rotatedPoints: [CGPoint] = [
            CGPoint(x: rect.minX - offset, y: rect.minY - offset).applying(transform),
            CGPoint(x: rect.maxX + offset, y: rect.minY - offset).applying(transform),
            CGPoint(x: rect.maxX + offset, y: rect.maxY + offset).applying(transform),
            CGPoint(x: rect.minX - offset, y: rect.maxY + offset).applying(transform)
        ]
        
        // Check if the point is within the convex hull of rotated points
        let convexHullPath = UIBezierPath()
        convexHullPath.move(to: rotatedPoints[0])
        convexHullPath.addLine(to: rotatedPoints[1])
        convexHullPath.addLine(to: rotatedPoints[2])
        convexHullPath.addLine(to: rotatedPoints[3])
        convexHullPath.close()
        
        return convexHullPath.contains(CGPoint(size: screenSize / 2))
    }
    
    func addMarker() {
        let newMarker = Marker(coordinates: backgroundMapDetails.position, insertInto: moc)
        
        for mapMap in mapMaps {
            if checkOverMapMap(mapMap: mapMap) {
                newMarker.addToMapMap(mapMap)
                return
            }
        }
        
        try? moc.save()
    }
}
