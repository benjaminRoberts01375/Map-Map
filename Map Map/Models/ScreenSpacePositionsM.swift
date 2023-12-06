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
