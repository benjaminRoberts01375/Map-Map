//
//  CropGrabberV.swift
//  Map Map
//
//  Created by Ben Roberts on 1/16/24.
//

import SwiftUI

struct CropGrabberV: View {
    /// Where to begin sampling line position from.
    @Binding var leadingPoint: CGSize
    /// Where to begin sampling line position from.
    @Binding var trailingPoint: CGSize
    /// Length of the crop grabber
    static let length: CGFloat = 50
    /// Angle of rotation for the Crop Grabber
    var rotationAngle: Angle {
        Angle(
            radians: atan2(
                leadingPoint.height - trailingPoint.height,
                leadingPoint.width - trailingPoint.width
            )
        )
    }
    /// Position of the CropGrabber
    var position: CGPoint {
        CGPoint(size: ((leadingPoint + trailingPoint) / 2))
    }
    
    /// When given a line and an arbitary point, determine where on the line is the closest.
    func closestPointToPointOnVector(pointA: CGPoint, pointB: CGPoint, vectorV: CGVector) -> CGSize {
        let vectorBA = CGVector(dx: pointB.x - pointA.x, dy: pointB.y - pointA.y) // Calculate the vector from A to B
        let dotProduct = vectorBA.dx * vectorV.dx + vectorBA.dy * vectorV.dy // Calculate the dot product
        let scalar = dotProduct / (pow(vectorV.dx, 2) + pow(vectorV.dy, 2)) // Calculate the scalar parameter
        return CGSize(width: pointA.x + scalar * vectorV.dx, height: pointA.y + scalar * vectorV.dy) // Calculate the closest point
    }
    
    var drag: some Gesture {
        DragGesture(coordinateSpace: .local)
            .onChanged { update in
                let vec = CGVector(dx: cos(rotationAngle.radians + CGFloat.pi / 2), dy: sin(rotationAngle.radians + CGFloat.pi / 2))
                let newPoint = closestPointToPointOnVector(pointA: position, pointB: update.location, vectorV: vec)
                let delta = newPoint - CGSize(cgPoint: position)
                leadingPoint += delta
                trailingPoint += delta
            }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25.0)
                .foregroundStyle(.white)
                .frame(width: 60, height: 10)
                .rotationEffect(rotationAngle)
                .position(position)
                .gesture(drag)
        }
    }
}
