//
//  MapUI.swift
//  Map Map
//
//  Created by Ben Roberts on 9/13/23.
//

import MapKit
import SwiftUI

/// Background map to be plotted on top of.
struct BackgroundMap: View {
    /// All available MapMaps.
    @FetchRequest(sortDescriptors: []) private var mapMaps: FetchedResults<MapMap>
    /// All available Markers.
    @FetchRequest(sortDescriptors: []) private var markers: FetchedResults<Marker>
    /// Background map details to be updated by this map.
    @Environment(BackgroundMapDetailsM.self) private var backgroundMapDetails: BackgroundMapDetailsM
    /// Track if MapMaps are tappable.
    @State private var tappableMapMaps = true
    /// Current editor
    @Binding var editor: Editor
    /// Background map ID.
    let mapScope: Namespace.ID
    /// Map context generated by a map reader.
    var mapContext: MapProxy
    
    var body: some View {
        @Bindable var backgroundMapDetails = backgroundMapDetails
        Map(
            position: $backgroundMapDetails.liveMapController,
            interactionModes: backgroundMapDetails.allowsInteraction ? [.pan, .rotate, .zoom] : [],
            scope: mapScope
        ) {
            ForEach(mapMaps) { mapMap in
                if let name = mapMap.mapMapName, mapMap.isSetup && !mapMap.isEditing && mapMap.shown {
                    Annotation(
                        "\(name)",
                        coordinate: mapMap.coordinates,
                        anchor: .center
                    ) {
                        let calculatedWidth = 1 / backgroundMapDetails.mapCamera.distance * mapMap.mapMapScale
                        let width = !calculatedWidth.isNormal || calculatedWidth < 0 ? 1 : calculatedWidth
                        ZStack {
                            if tappableMapMaps {
                                Button(
                                    action: { backgroundMapDetails.moveMapCameraTo(mapMap: mapMap) },
                                    label: {
                                        MapMapV(mapMap: mapMap, mapType: .fullImage)
                                            .frame(width: width)
                                    }
                                )
                                .contextMenu { MapMapContextMenuV(mapMap: mapMap) }
                            }
                            else {
                                MapMapV(mapMap: mapMap, mapType: .fullImage)
                                    .frame(width: width)
                            }
                            if let drawing = mapMap.drawing, let pkDrawing = drawing.pkDrawing {
                                GeometryReader { _ in   
                                    DisplayDrawingV(drawing: pkDrawing)
                                        .frame(width: drawing.mapMapWidth, height: drawing.mapMapHeight)
                                        .scaleEffect(width / drawing.mapMapWidth, anchor: .topLeading)
                                        .allowsHitTesting(false)
                                }
                            }
                        }
                        .rotationEffect(Angle(degrees: -backgroundMapDetails.mapCamera.heading - mapMap.mapMapRotation))
                        .offset(y: -7)
                    }
                }
            }
        }
        .mapControlVisibility(.hidden)
        .onMapCameraChange(frequency: .continuous) { update in
            backgroundMapDetails.region = update.region
            backgroundMapDetails.mapCamera = update.camera
        }
        .mapStyle(.standard(elevation: .realistic))
        .onChange(of: editor, { _, newValue in
            switch newValue {
            case .nothing:
                tappableMapMaps = true
            default:
                tappableMapMaps = false
            }
        })
    }
    
    /// Given a specific rotation and MapMap, a UIBezierPath is formed to allow for precise calculations.
    /// - Parameters:
    ///   - mapMap: MapMap to generate a rotated bounding box for.
    ///   - backgroundMapRotation: Background map rotation.
    ///   - mapContext: A `MapProxy` that is generated by a `MapReader` to allow for mapping of lat/long coordinates to screen-space.
    /// - Returns: A bounding box of a MapMap that has been rotated to match the MapMap.
    public static func generateMapMapRotatedConvexHull(
        mapMap: MapMap,
        backgroundMapDetails: BackgroundMapDetailsM,
        mapContext: MapProxy
    ) -> UIBezierPath? {
        guard let rect: CGRect = BackgroundMap.generateMapMapBounds(
            mapMap,
            mapContext: mapContext,
            backgroundMapScale: 1 / backgroundMapDetails.mapCamera.distance
        )
        else { return nil }
        let transform = CGAffineTransform(translationX: rect.midX - rect.width / 2, y: rect.midY - rect.height / 2)
            .rotated(by: Angle(degrees: -backgroundMapDetails.mapCamera.heading - mapMap.mapMapRotation).radians)
            .translatedBy(x: -rect.midX, y: -rect.midY)
        let padding: CGFloat = 25
        let rotatedPoints: [CGPoint] = // Calculate rotated points
        [
            CGPoint(x: rect.minX - padding, y: rect.minY - padding).applying(transform),
            CGPoint(x: rect.maxX + padding, y: rect.minY - padding).applying(transform),
            CGPoint(x: rect.maxX + padding, y: rect.maxY + padding).applying(transform),
            CGPoint(x: rect.minX - padding, y: rect.maxY + padding).applying(transform)
        ]
        // Check if the point is within the convex hull of rotated points
        let convexHullPath = UIBezierPath()
        convexHullPath.move(to: rotatedPoints[0])
        convexHullPath.addLine(to: rotatedPoints[1])
        convexHullPath.addLine(to: rotatedPoints[2])
        convexHullPath.addLine(to: rotatedPoints[3])
        convexHullPath.close()
        return convexHullPath
    }
    
    /// Creates a bounding box for a given MapMap.
    /// - Parameters:
    ///   - mapMap: MapMap to generate the bounding box for.
    ///   - mapContext: A `MapProxy` that is generated by a `MapReader` to allow for mapping of lat/long coordinates to screen-space.
    ///   - backgroundMapScale: Scale of the background map.
    /// - Returns: Bounds of the MapMap.
    public static func generateMapMapBounds(_ mapMap: MapMap, mapContext: MapProxy, backgroundMapScale: CGFloat) -> CGRect? {
        guard let center = mapContext.convert(mapMap.coordinates, to: .local)
        else { return nil }
        let size = backgroundMapScale * mapMap.mapMapScale
        return CGRect(
            origin: center,
            size: CGSize(
                width: size,
                height: size / mapMap.imageWidth * mapMap.imageHeight
            )
        )
    }
}
