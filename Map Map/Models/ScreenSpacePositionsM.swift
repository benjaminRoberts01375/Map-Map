//
//  ScreenSpacePositionsM.swift
//  Map Map
//
//  Created by Ben Roberts on 12/6/23.
//

import SwiftUI

@Observable
final class ScreenSpacePositionsM {
    public var markerPositions: [Marker : CGPoint] = [:]
    public var mapMapPositions: [MapMap : CGRect] = [:]
    public var userLocation: CGPoint? = nil
    
    func mapMapOverMarkers(_ mapMap: MapMap, backgroundMapRotation: Angle) -> [Marker]? {
        guard let mapMapBounds = generateMapMapRotatedBounds(mapMap: mapMap, backgroundMapRotation: backgroundMapRotation)?.cgPath
        else { return nil }
        var markers: [Marker] = []
        
        for (marker, _) in markerPositions {
            if let markerPosition = markerPositions[marker] {
                let markerBounds = UIBezierPath(ovalIn: CGRect(origin: markerPosition, size: CGSize(width: BackgroundMapPointsV.iconSize, height: BackgroundMapPointsV.iconSize))).cgPath
                if mapMapBounds.intersects(markerBounds) {
                    markers.append(marker)
                }
            }
        }
        
        return markers
    }
    
    func markerOverMapMaps(_ marker: Marker, backgroundMapRotation: Angle) -> [MapMap]? {
        guard let markerPosition = markerPositions[marker] else {
            return nil
        }
        let marker = UIBezierPath(ovalIn: CGRect(origin: markerPosition, size: CGSize(width: BackgroundMapPointsV.iconSize, height: BackgroundMapPointsV.iconSize))).cgPath
        var mapMaps: [MapMap] = []
        for (mapMap, _) in mapMapPositions {
            if let mapMapBounds = generateMapMapRotatedBounds(mapMap: mapMap, backgroundMapRotation: backgroundMapRotation)?.cgPath,
                mapMapBounds.intersects(marker) {
                mapMaps.append(mapMap)
            }
        }
        return mapMaps
    }
    
    func generateMapMapRotatedBounds(mapMap: MapMap, backgroundMapRotation: Angle) -> UIBezierPath? {
        guard let rect: CGRect = mapMapPositions[mapMap]
        else { return nil }
        
        let transform = CGAffineTransform(translationX: rect.midX - rect.width / 2, y: rect.midY - rect.height / 2)
            .rotated(by: (backgroundMapRotation - Angle(degrees: mapMap.mapMapRotation)).radians)
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
        
        return convexHullPath
    }
}
