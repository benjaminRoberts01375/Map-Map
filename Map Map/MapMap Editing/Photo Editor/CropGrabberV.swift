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
    
    var body: some View {
        RoundedRectangle(cornerRadius: 25.0)
            .foregroundStyle(.white)
            .frame(width: 60, height: 10)
            .rotationEffect(rotationAngle)
            .position(position)
    }
}
