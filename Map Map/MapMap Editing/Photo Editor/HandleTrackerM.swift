//
//  HandleTrackerM.swift
//  Map Map
//
//  Created by Ben Roberts on 11/12/23.
//

import SwiftUI

/// Contain data about handles.
@Observable
final class HandleTrackerM {
    /// Current corners.
    var corners: FourCornersStorage
    /// Initial corners.
    let initialCorners: FourCornersStorage
    
    /// Create a handle tracker from a FourCorners.
    /// - Parameter corners: Corners from a MapMap.
    init(corners: FourCorners) {
        let corners = FourCornersStorage(corners: corners)
        self.corners = corners
        self.initialCorners = corners
    }
    
    /// Create a four corners from width and height.
    /// - Parameters:
    ///   - width: Horizontal distance between corners.
    ///   - height: Vertical distance between corners.
    init(width: CGFloat, height: CGFloat) {
        let corners = FourCornersStorage(
            topLeading: .zero,
            topTrailing: CGSize(width: width, height: .zero),
            bottomLeading: CGSize(width: .zero, height: height),
            bottomTrailing: CGSize(width: width, height: height)
        )
        self.corners = corners
        self.initialCorners = corners
    }
}
