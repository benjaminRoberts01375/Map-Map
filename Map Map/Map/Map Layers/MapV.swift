//
//  MapUI.swift
//  Map Map
//
//  Created by Ben Roberts on 9/13/23.
//

import MapKit
import SwiftUI

/// Map to be plotted on top of.
struct MapV: View {
    /// All available MapMaps.
    @FetchRequest(sortDescriptors: []) private var mapMaps: FetchedResults<MapMap>
    /// All available Markers.
    @FetchRequest(sortDescriptors: []) private var markers: FetchedResults<Marker>
    /// Map details to be updated by this map.
    @Environment(MapDetailsM.self) private var mapDetails: MapDetailsM
    /// Track if MapMaps are tappable.
    @State private var tappableMapMaps: MapMapAnnotationV.MapMapInteraction = .tappable
    /// Current editor
    @Binding var editor: Editor
    /// map ID.
    let mapScope: Namespace.ID
    
    var body: some View {
        @Bindable var mapDetails = mapDetails
        Map(
            position: $mapDetails.liveMapController,
            interactionModes: mapDetails.allowsInteraction ? [.pan, .rotate, .zoom] : [],
            scope: mapScope
        ) {
            ForEach(mapMaps) { mapMap in
                if let name = mapMap.mapMapName, mapMap.isSetup && !mapMap.isEditing && mapMap.shown {
                    Annotation(
                        "\(name)",
                        coordinate: mapMap.coordinate,
                        anchor: .center
                    ) {
                        MapMapAnnotationV(mapMap: mapMap, mapMapInteraction: tappableMapMaps)
                            .environment(mapDetails)
                    }
                }
            }
        }
        .mapControlVisibility(.hidden)
        .onMapCameraChange(frequency: .continuous) { update in
            mapDetails.region = update.region
            mapDetails.mapCamera = update.camera
        }
        .mapStyle(.standard(elevation: .realistic))
        .onChange(of: editor) { _, newValue in
            switch newValue {
            case .nothing:
                tappableMapMaps = .tappable
            default:
                tappableMapMaps = .viewable
            }
        }
    }
    
    /// Given a specific rotation and MapMap, a UIBezierPath is formed to allow for precise calculations.
    /// - Parameters:
    ///   - mapMap: MapMap to generate a rotated bounding box for.
    ///   - mapRotation: Map rotation.
    ///   - mapContext: A `MapProxy` that is generated by a `MapReader` to allow for mapping of lat/long coordinates to screen-space.
    /// - Returns: A bounding box of a MapMap that has been rotated to match the MapMap.
    public static func generateMapMapRotatedConvexHull(
        mapMap: MapMap,
        mapDetails: MapDetailsM,
        mapContext: MapProxy
    ) -> UIBezierPath? {
        guard let rect: CGRect = MapV.generateMapMapBounds(
            mapMap,
            mapContext: mapContext,
            mapScale: 1 / mapDetails.mapCamera.distance
        )
        else { return nil }
        let transform = CGAffineTransform(translationX: rect.midX - rect.width / 2, y: rect.midY - rect.height / 2)
            .rotated(by: Angle(degrees: -mapDetails.mapCamera.heading - mapMap.mapMapRotation).radians)
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
    ///   - mapScale: Scale of the map.
    /// - Returns: Bounds of the MapMap.
    public static func generateMapMapBounds(_ mapMap: MapMap, mapContext: MapProxy, mapScale: CGFloat) -> CGRect? {
        guard let center = mapContext.convert(mapMap.coordinate, to: .local),
              let imageSize = mapMap.imageSize
        else { return nil }
        let size = mapScale * mapMap.mapMapScale
        return CGRect(
            origin: center,
            size: CGSize(
                width: size,
                height: size / imageSize.width * imageSize.height
            )
        )
    }
}
