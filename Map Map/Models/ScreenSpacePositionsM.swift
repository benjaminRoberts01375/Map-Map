//
//  ScreenSpacePositionsM.swift
//  Map Map
//
//  Created by Ben Roberts on 12/6/23.
//

import SwiftUI

@Observable
final class ScreenSpacePositionsM {
    /// A dictionary of Markers and their associated background map screen-space positions.
    private var markerPositions: [Marker : CGPoint] = [:]
    /// A dictionary of MapMaps and their associated background map screen-space positions and sizes.
    private var mapMapPositions: [MapMap : CGRect] = [:]
    /// Storage for the user's location in screen-space on the background map.
    public var userLocation: CGPoint?
    
    subscript(marker: Marker) -> CGPoint? {
        get { return markerPositions[marker] }
        set(newMarkerPos) { markerPositions[marker] = newMarkerPos }
    }    
    subscript(mapMap: MapMap) -> CGRect? {
        get { return mapMapPositions[mapMap] }
        set(newMapMapPos) { mapMapPositions[mapMap] = newMapMapPos }
    }
    
    func removeValue(forKey marker: Marker) {
        markerPositions.removeValue(forKey: marker)
    }
    
    func setPositions(_ updatedPositions: [Marker : CGPoint]) {
        self.markerPositions = updatedPositions
    }
    
    func setPositions(_ updatedPositions: [MapMap : CGRect]) {
        self.mapMapPositions = updatedPositions
    }
    
    /// Determine all Markers that overlap a given MapMap
    /// - Parameters:
    ///   - mapMap: MapMap to check Marker positions against.
    ///   - backgroundMapRotation: Background map rotation.
    /// - Returns: If the MapMap's position in screen-space was not found, then nil is returned. 
    /// Otherwise, all available Markers are returned.
    public func mapMapOverMarkers(_ mapMap: MapMap, backgroundMapRotation: Angle) -> [Marker]? {
        guard let mapMapBounds = generateMapMapRotatedBounds(mapMap: mapMap, backgroundMapRotation: backgroundMapRotation)?.cgPath
        else { return nil }
        var markers: [Marker] = []
        
        for (marker, _) in markerPositions {
            if let markerPosition = markerPositions[marker] {
                let markerBounds = generateMarkerBoundingBox(markerPosition: markerPosition)
                if mapMapBounds.intersects(markerBounds) {
                    markers.append(marker)
                }
            }
        }
        return markers
    }
    
    /// Determine all MapMaps that overlap a given Marker
    /// - Parameters:
    ///   - marker: Marker to check MapMap positions against.
    ///   - backgroundMapRotation: Background map rotation.
    /// - Returns: If the Marker's position in screen-space was not found, then nil is returned. 
    /// Otherwise, all available MapMaps are returned.
    public func markerOverMapMaps(_ marker: Marker, backgroundMapRotation: Angle) -> [MapMap]? {
        guard let markerPosition = markerPositions[marker] else {
            return nil
        }
        let marker = generateMarkerBoundingBox(markerPosition: markerPosition)
        var mapMaps: [MapMap] = []
        for (mapMap, _) in mapMapPositions {
            if let mapMapBounds = generateMapMapRotatedBounds(mapMap: mapMap, backgroundMapRotation: backgroundMapRotation)?.cgPath,
                mapMapBounds.intersects(marker) {
                mapMaps.append(mapMap)
            }
        }
        return mapMaps
    }
    
    /// Given a specific rotation and MapMap, a UIBezierPath is formed to allow for precise calculations.
    /// - Parameters:
    ///   - mapMap: MapMap to generate a rotated bounding box for.
    ///   - backgroundMapRotation: Background map rotation.
    /// - Returns: A bounding box of a MapMap that has been rotated to match the MapMap.
    public func generateMapMapRotatedBounds(mapMap: MapMap, backgroundMapRotation: Angle) -> UIBezierPath? {
        guard let rect: CGRect = mapMapPositions[mapMap]
        else { return nil }
        let transform = CGAffineTransform(translationX: rect.midX - rect.width / 2, y: rect.midY - rect.height / 2)
            .rotated(by: (backgroundMapRotation - Angle(degrees: mapMap.mapMapRotation)).radians)
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
    
    /// Generate a Marker's bounding box
    /// - Parameter markerPosition: Center point of the bounding box.
    /// - Returns: A CGPath of a circle centered at the marker position.
    private func generateMarkerBoundingBox(markerPosition: CGPoint) -> CGPath {
        return UIBezierPath(
            ovalIn: CGRect(
                origin: markerPosition,
                size: CGSize(
                    width: BackgroundMapPointsV.iconSize,
                    height: BackgroundMapPointsV.iconSize
                )
            )
        ).cgPath
    }
}
