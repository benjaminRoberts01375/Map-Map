//
//  UIImage.swift
//  Map Map
//
//  Created by Ben Roberts on 11/12/23.
//

import UIKit

extension UIImage {
    /// Wipe any rotation or mirror from the UIImage.
    /// - Returns: The corrected UIImage.
    public func fixOrientation() -> UIImage {
        // Nothing to do
        if imageOrientation == .up { return self }
        guard let cgImage = cgImage else { return self }
        let width = size.width
        let height = size.height
        let transform = determineTransformForStandardImage()
        if let colorSpace = cgImage.colorSpace, // Remake UIImage from CGImage
            let context = CGContext(
                data: nil,
                width: Int(width),
                height: Int(height),
                bitsPerComponent: cgImage.bitsPerComponent,
                bytesPerRow: 0,
                space: colorSpace,
                bitmapInfo: cgImage.bitmapInfo.rawValue
            ) {
            // Apply the calculated transform to the context.
            context.concatenate(transform)
            if imageOrientation == .left || // Draw the image into the context, taking care of the dimensions and orientation.
                imageOrientation == .leftMirrored ||
                imageOrientation == .right ||
                imageOrientation == .rightMirrored {
                context.draw(cgImage, in: CGRect(x: 0, y: 0, width: height, height: width))
            } 
            else { context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height)) }
            // Create a new UIImage from the context's CGImage.
            if let correctedCGImage = context.makeImage() {
                return UIImage(cgImage: correctedCGImage)
            }
        }
        return self // Not able to recreate UIImage, abort
    }
    
    private func determineTransformForStandardImage() -> CGAffineTransform {
        let width = size.width
        let height = size.height
        var transform = CGAffineTransform.identity
        
        switch imageOrientation { // Rotate
        case .down, .downMirrored:
            transform = transform.translatedBy(x: width, y: height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: width, y: 0)
            transform = transform.rotated(by: .pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: height)
            transform = transform.rotated(by: -.pi / 2)
        default:
            break
        }
        
        if imageOrientation == .upMirrored || imageOrientation == .downMirrored { // Fix any mirror annoyances
            transform = transform.translatedBy(x: width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        else if imageOrientation == .leftMirrored || imageOrientation == .rightMirrored { // Fix any mirror annoyances
            transform = transform.translatedBy(x: height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        return transform
    }
}
