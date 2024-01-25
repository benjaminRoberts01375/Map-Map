//
//  MapMapAnnotationV.swift
//  Map Map
//
//  Created by Ben Roberts on 1/25/24.
//

import SwiftUI

/// Handle all display logic for a MapMap on the map.
struct MapMapAnnotationV: View {
    /// Map details to be updated by this map.
    @Environment(MapDetailsM.self) private var mapDetails
    /// MapMap being displayed.
    @ObservedObject var mapMap: FetchedResults<MapMap>.Element
    /// Update UI when drawing changes.
    @State var id: UUID = UUID()
    /// Track the current interaction of this mapmap.
    let mapMapInteraction: MapMapInteraction
    
    /// Type for map interactions.
    enum MapMapInteraction {
        case tappable
        case viewable
    }
    
    var body: some View {
        let calculatedWidth = 1 / mapDetails.mapCamera.distance * mapMap.mapMapScale
        let width = !calculatedWidth.isNormal || calculatedWidth < 0 ? 1 : calculatedWidth
        ZStack {
            switch mapMapInteraction {
            case .tappable:
                Button(
                    action: { mapDetails.moveMapCameraTo(mapMap: mapMap) },
                    label: {
                        MapMapV(mapMap: mapMap, mapType: .fullImage)
                            .frame(width: width)
                    }
                )
                .contextMenu { MapMapContextMenuV(mapMap: mapMap) }
            case .viewable:
                MapMapV(mapMap: mapMap, mapType: .fullImage)
                    .frame(width: width)
            }
            if let drawing = mapMap.drawing, let pkDrawing = drawing.pkDrawing {
                GeometryReader { _ in
                    DisplayDrawingV(drawing: pkDrawing)
                        .frame(width: drawing.mapMapWidth, height: drawing.mapMapHeight)
                        .scaleEffect(width / drawing.mapMapWidth, anchor: .topLeading)
                        .allowsHitTesting(false)
                        .onChange(of: drawing.drawingData) { self.id = UUID() }
                }
                .id(id)
            }
        }
        .rotationEffect(Angle(degrees: -mapDetails.mapCamera.heading - mapMap.mapMapRotation))
        .offset(y: -7)
    }
}
