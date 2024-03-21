//
//  MapMapAnnotationV.swift
//  Map Map
//
//  Created by Ben Roberts on 1/25/24.
//

import SwiftUI

/// Handle all display logic for a MapMap on the map.
struct MapMapAnnotatedV: View {
    /// Map details to be updated by this map.
    @Environment(MapDetailsM.self) private var mapDetails
    /// MapMap being displayed.
    @ObservedObject var mapMap: MapMap
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
        let calculatedWidth = 1 / mapDetails.mapCamera.distance * mapMap.scale
        let width = !calculatedWidth.isNormal || calculatedWidth < 0 ? 1 : calculatedWidth
        ZStack {
            switch mapMapInteraction {
            case .tappable:
                Button(
                    action: { mapDetails.moveMapCameraTo(item: mapMap) },
                    label: {
                        MapMapV(mapMap, imageType: .image)
                            .frame(width: width)
                    }
                )
                .contextMenu { MapMapContextMenuV(mapMap: mapMap) }
            case .viewable:
                MapMapV(mapMap, imageType: .image)
                    .frame(width: width)
            }
            if let drawing = mapMap.unwrappedMapMapImageContainers.first?.unwrappedImages.last?.drawing,
                let pkDrawing = drawing.pkDrawing {
                GeometryReader { _ in
                    DisplayDrawingV(drawing: pkDrawing)
                        .frame(width: drawing.width, height: drawing.height)
                        .scaleEffect(width / drawing.width, anchor: .topLeading)
                        .allowsHitTesting(false)
                        .onChange(of: drawing.drawingData) { self.id = UUID() }
                }
                .id(id)
            }
        }
        .rotationEffect(Angle(degrees: -mapDetails.mapCamera.heading - mapMap.mapRotation))
        .offset(y: -7)
    }
}
